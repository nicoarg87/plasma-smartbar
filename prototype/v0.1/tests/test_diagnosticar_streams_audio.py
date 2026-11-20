#!/usr/bin/env python3
"""Pruebas sin acceso a PipeWire real y sin cambios de audio."""
import contextlib
import importlib.util
import io
import json
from pathlib import Path
import unittest
from unittest.mock import patch

MODULE = Path(__file__).resolve().parents[1] / "scripts" / "diagnosticar_streams_audio.py"
SPEC = importlib.util.spec_from_file_location("diagnosticar_audio", MODULE)
audio = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(audio)


class DiagnoseAudioTests(unittest.TestCase):
    def sample(self):
        return [
            {"id": 15, "type": "PipeWire:Interface:Client/3",
             "info": {"props": {"application.name": "Brave",
                                "application.process.id": "350",
                                "application.id": "com.brave.Browser"}}},
            {"id": 120, "type": "PipeWire:Interface:Node/3",
             "info": {"state": "running", "props": {
                 "media.class": "Stream/Output/Audio",
                 "client.id": 15, "application.name": "Brave"}}},
            {"id": 125, "type": "PipeWire:Interface:Client/3",
             "info": {"props": {"application.name": "Brave"}}},
            {"id": 57, "type": "PipeWire:Interface:Node/3",
             "info": {"props": {"media.class": "Audio/Sink"}}},
            {"id": 58, "type": "PipeWire:Interface:Node/3",
             "info": {"props": {"media.class": "Stream/Input/Audio"}}},
            {"id": 140, "type": "PipeWire:Interface:Node/3",
             "info": {"props": {"media.class": "Stream/Output/Audio",
                               "application.name": "Konsole"}}},
        ]

    def test_only_output_audio_stream_nodes(self):
        streams = audio.streams_from_dump(self.sample())
        self.assertEqual([s["id"] for s in streams], [120, 140])
        self.assertEqual(streams[0]["application"], "Brave")
        self.assertEqual(streams[0]["desktop_id"], "com.brave.Browser")
        self.assertEqual(streams[0]["pid"], "350")

    def test_client_with_reused_id_is_not_a_stream(self):
        self.assertNotIn(125, [s["id"] for s in
                               audio.streams_from_dump(self.sample())])

    def test_does_not_guess_missing_metadata(self):
        second = audio.streams_from_dump(self.sample())[1]
        self.assertEqual(second["desktop_id"], "—")
        self.assertEqual(second["pid"], "—")

    def test_malformed_json_structure_rejected(self):
        with self.assertRaises(ValueError):
            audio.streams_from_dump({"nodes": []})

    def test_control_characters_stripped(self):
        self.assertEqual(audio.clean("Brave\x1b[31m\n"), "Brave [31m")

    def test_stdin_mode_never_executes_commands(self):
        captured = io.StringIO()
        with patch.object(audio.sys, "stdin", io.StringIO(json.dumps(self.sample()))):
            with patch.object(audio.subprocess, "run",
                              side_effect=AssertionError("No subprocess allowed")):
                with contextlib.redirect_stdout(captured):
                    code = audio.main(["--stdin"])
        self.assertEqual(code, 0)
        self.assertIn("Streams de reproducción detectados: 2",
                      captured.getvalue())
        self.assertIn("No se alteró el volumen", captured.getvalue())


if __name__ == "__main__":
    unittest.main()
