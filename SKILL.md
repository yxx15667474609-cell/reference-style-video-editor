---
name: reference-style-video-editor
description: Analyze a Jianying/剪映/CapCut project or reference video and edit a new local footage folder to match its copy, narrative structure, pacing, captions, sound design, color, and CTA, then export and QA an MP4. Use when the user asks to 学习、复刻或沿用参考工程/成片的剪辑风格，用新素材重剪，按照原脚本文案对齐画面，自动剪辑信息流广告，交付竖屏短视频，或从剪映当前页面读取参考项目。
---

# Reference Style Video Editor

Reconstruct the reference's editing grammar with new footage while preserving source files and producing a verified final MP4.

## Resolve the assignment

Collect or discover:

- Reference source: active Jianying project, project folder, finished video, or any combination.
- New-footage folder; treat the resolved folder as an allowlist and never mix similarly named folders.
- Copy/voice policy: reuse the original copy, reuse authorized reference audio, or create new copy/voice.
- Output duration, aspect ratio, language, and required deliverables.

Resolve flattened or ambiguous paths by checking the filesystem. Prefer safe assumptions when the user requests autonomous work. Ask only when the missing choice would materially change the result.

Keep all reference projects and raw media read-only unless the user explicitly requests an editable project. Write intermediates to a dedicated work directory and the final video to a new path.

## Choose the execution path

- Use the `computer-use` skill to inspect an already-open Jianying project or to produce an editable Jianying draft.
- Use local FFmpeg/HyperFrames for deterministic MP4-only delivery.
- Use the `hyperframes-media` skill when speech transcription, TTS, or caption timing is needed.
- Read [references/jianying-project.md](references/jianying-project.md) only when the reference is a live Jianying project.
- Read [references/editing-playbook.md](references/editing-playbook.md) for detailed timing, caption, audio, and QA conventions.

Do not claim a video was edited in Jianying when it was rendered by another pipeline.

## Build a reference style contract

Inspect the full reference, not only the opening:

1. Probe duration, resolution, frame rate, codecs, and audio layout.
2. Generate an evenly sampled contact sheet with `scripts/contact_sheet.sh`.
3. Transcribe the narration and inspect every segment; use `scripts/transcribe_folder.py` when MLX Whisper is available.
4. Record narrative beats, average shot length, speed ramps, reframing, transitions, caption geometry, color treatment, music/SFX, and CTA behavior.
5. Convert the observations into a time-coded style contract:
   `hook → pain/problem → discovery → product proof/demo → benefit/result → CTA`.

Prefer the reference's actual timing over generic short-video heuristics.

## Index and select new footage

1. Run `scripts/media_inventory.sh` on the allowlisted footage folder.
2. Create folder and clip-level contact sheets.
3. Transcribe clips containing dialogue; treat model output as evidence to verify, not ground truth.
4. Tag usable moments by action, emotion, product visibility, composition, and continuity.
5. Match each reference beat semantically. Use speed changes and punch-ins to fit timing; do not choose shots only because their source timecodes resemble the reference.

If the new footage has no complete narration and the user authorized reuse of the original script/audio, preserve the reference narration and rebuild the visual track around it. Otherwise create new narration rather than silently copying reference audio.

## Plan before rendering

Create a timing table containing:

| Output in-out | Beat/copy | Source clip in-out | Speed | Crop/reframe | Caption/SFX |
|---|---|---|---|---|---|

Make the final duration voice-driven unless the user specifies an exact duration. Keep hook cuts fast, give product/application actions enough screen time to read, and reserve a clear final CTA beat.

## Render

1. Normalize all shots to the target canvas, frame rate, SAR, and color space.
2. Reframe faces, hands, products, and application areas deliberately.
3. Recreate caption wording and timing from the authorized copy. Start from `assets/captions-template.ass` for 9:16 videos.
4. Retain intelligible narration. Add restrained, motivated SFX at reveals, steps, transitions, and CTA moments.
5. Export H.264 High, yuv420p, AAC 48 kHz, and `+faststart` unless the user requests another format.
6. Strip unintended timecode/data tracks from the delivery file.

## Mandatory quality gate

Before delivery:

1. Decode the entire file with errors treated as fatal.
2. Run `scripts/qa_video.sh` and review black-frame, frozen-frame, loudness, stream, and duration output.
3. Generate and visually inspect a final contact sheet.
4. Re-transcribe the final audio and compare the complete copy, ordering, and timing against the approved script.
5. Verify captions stay inside the safe area and do not cover the face, product, hands, or CTA.
6. Confirm the output uses only allowed footage and that the original files are unchanged.

Deliver the absolute clickable file path, duration, dimensions, frame rate, codec, and a concise description of what was preserved or changed.
