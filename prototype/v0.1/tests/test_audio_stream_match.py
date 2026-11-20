#!/usr/bin/env python3
"""Regresiones offline del cruce KDE/PipeWire (NUNCA escribe volumen)."""
import contextlib
import importlib.util
import io
import json
from pathlib import Path
import sys
import unittest
from unittest.mock import patch

SCRIPTS = Path(__file__).resolve().parents[1] / "scripts"
sys.path.insert(0, str(SCRIPTS))

from audio_stream_match import match_kde_app_id  # noqa: E402

CLI_SPEC = importlib.util.spec_from_file_location(
    "verificar_correspondencia_audio", SCRIPTS / "verificar_correspondencia_audio.py")
cli = importlib.util.module_from_spec(CLI_SPEC)
CLI_SPEC.loader.exec_module(cli)


def client(n, app_id=None, **extras):
    props = dict(extras)
    if app_id is not None:
        props["application.id"] = app_id
    return {"type": "PipeWire:Interface:Client/3", "id": n,
            "info": {"props": props}}


def node(n, app_id=None, client_id=None, media_class="Stream/Output/Audio",
         **extras):
    props = {"media.class": media_class}
    if app_id is not None:
        props["application.id"] = app_id
    if client_id is not None:
        props["client.id"] = client_id
    props.update(extras)
    return {"type": "PipeWire:Interface:Node/3", "id": n,
            "info": {"props": props}}


class AudioStreamMatchTests(unittest.TestCase):
    APP = "com.brave.Browser"

    def test_zero_nodes(self):
        actual = match_kde_app_id(self.APP, [])
        self.assertEqual(actual["status"], "none")
        self.assertEqual(actual["nodes"], [])

    def test_one_exact_match(self):
        actual = match_kde_app_id(self.APP, [node(116, self.APP)])
        self.assertEqual(actual["status"], "single")
        self.assertEqual(actual["nodes"], [116])

    def test_two_nodes_for_same_application(self):
        actual = match_kde_app_id(self.APP, [node(121, self.APP),
                                              node(119, self.APP)])
        self.assertEqual(actual["status"], "multiple")
        self.assertEqual(actual["nodes"], [119, 121])

    def test_sink_source_and_client_not_streams(self):
        sample = [node(57, self.APP, media_class="Audio/Sink"),
                  node(58, self.APP, media_class="Stream/Input/Audio"),
                  client(119, self.APP)]
        actual = match_kde_app_id(self.APP, sample)
        self.assertEqual(actual["status"], "none")
        self.assertEqual(actual["streams_seen"], 0)

    def test_reused_numeric_node_id_never_inferred(self):
        sample = [client(119, self.APP), node(116, self.APP)]
        actual = match_kde_app_id(self.APP, sample)
        self.assertEqual(actual["nodes"], [116])

    def test_client_id_fallback(self):
        sample = [client(42, self.APP), node(116, client_id=42)]
        self.assertEqual(match_kde_app_id(self.APP, sample)["nodes"], [116])

    def test_node_and_client_disagree_fail_closed(self):
        sample = [client(42, "org.other.Player"),
                  node(116, self.APP, client_id=42)]
        actual = match_kde_app_id(self.APP, sample)
        self.assertEqual(actual["status"], "conflict")
        self.assertEqual(actual["nodes"], [])
        self.assertEqual(actual["conflicts"], [116])

    def test_matching_one_and_conflicting_another_blocks_certainty(self):
        sample = [node(116, self.APP),
                  client(42, "org.other.Player"),
                  node(117, self.APP, client_id=42)]
        actual = match_kde_app_id(self.APP, sample)
        self.assertEqual(actual["status"], "conflict")
        self.assertEqual(actual["nodes"], [116])

    def test_portal_id_mismatch_is_conflict(self):
        sample = [node(116, self.APP,
                       **{"pipewire.access.portal.app_id": "org.other.Player"})]
        self.assertEqual(match_kde_app_id(self.APP, sample)["status"],
                         "conflict")

    def test_missing_identity_no_guess_by_app_name(self):
        sample = [node(116, **{"application.name": "Brave",
                               "application.process.binary": "brave",
                               "application.process.id": "350"})]
        actual = match_kde_app_id(self.APP, sample)
        self.assertEqual(actual["status"], "none")
        self.assertEqual(actual["unidentified"], 1)

    def test_no_casefold_or_suffix_aliases(self):
        sample = [node(116, "com.brave.browser")]
        self.assertEqual(match_kde_app_id(self.APP, sample)["nodes"], [])
        self.assertEqual(match_kde_app_id("com.brave.browser.desktop", sample)
                         ["nodes"], [])

    def test_other_app_nodes_ignored(self):
        sample = [node(116, "org.mozilla.firefox"),
                  node(117, self.APP)]
        self.assertEqual(match_kde_app_id(self.APP, sample)["nodes"], [117])

    def test_malformed_and_blank_app_ids_rejected(self):
        for value in ("", " ", "com.brave.Browser ", "com/brave",
                      "brave\nother", "a" * 256, None, 350):
            self.assertEqual(match_kde_app_id(value, [node(116, self.APP)])
                             ["status"], "invalid")

    def test_truncated_metadata_not_accepted_as_exact_match(self):
        long_identity = "org.example." + "x" * 90
        sample = [node(116, long_identity)]
        self.assertEqual(match_kde_app_id(long_identity[:72], sample)
                         ["nodes"], [])

    def test_noncanonical_numeric_node_not_accepted(self):
        sample = [node("00116", self.APP), node(-5, self.APP),
                  node(116, self.APP)]
        self.assertEqual(match_kde_app_id(self.APP, sample)["nodes"], [116])

    def test_non_list_dump_is_rejected(self):
        with self.assertRaises(ValueError):
            match_kde_app_id(self.APP, {"nodes": []})

    def test_cli_stdin_has_no_external_commands(self):
        sample = [node(116, self.APP), node(117, self.APP)]
        captured = io.StringIO()
        with patch.object(cli.sys, "stdin", io.StringIO(json.dumps(sample))):
            with patch.object(cli.subprocess, "run",
                              side_effect=AssertionError("No command expected")):
                with contextlib.redirect_stdout(captured):
                    status = cli.main(["--stdin", "--kde-app-id", self.APP])
        self.assertEqual(status, 0)
        self.assertIn("Varios streams", captured.getvalue())
        self.assertIn("116, 117", captured.getvalue())
        self.assertIn("No se alteró el sonido", captured.getvalue())


if __name__ == "__main__":
    unittest.main()
