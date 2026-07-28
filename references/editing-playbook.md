# Editing Playbook

## Style contract

Record these fields before selecting shots:

| Field | Evidence to capture |
|---|---|
| Delivery | duration, canvas, fps, codecs, loudness |
| Narrative | hook, pain, discovery, proof/demo, benefit, CTA |
| Rhythm | cut points, average shot length, pauses, speed ramps |
| Framing | close/medium/wide mix, punch-ins, product position |
| Captions | exact copy, line length, font, size, outline, vertical safe area |
| Motion | transitions, zooms, freezes, overlays, CTA animation |
| Look | exposure, contrast, saturation, temperature, sharpening |
| Audio | narration, music bed, reveals, whooshes, clicks, CTA cue |

Use time-coded evidence. Distinguish direct observation from inference.

## Timing rules

- Anchor edits to narration phrase boundaries.
- Cut the first problem sequence quickly; 0.7–1.8 seconds per shot is a useful starting range, not a requirement.
- Let product identification and application shots remain readable.
- Use accelerated source footage only when the action remains understandable.
- Keep the result sequence emotionally opposite to the problem sequence.
- Reserve the final 2–4 seconds for a product-visible CTA.
- Prefer hard cuts when the reference is direct-response UGC; add transitions only where the reference uses them.

## Captions

- Preserve approved wording, capitalization, and product spelling.
- Split on spoken phrases rather than fixed character counts.
- For 1080×1920, begin around 42–54 px with a 3–4 px dark outline.
- Keep captions above platform controls and below the face unless the product occupies that zone.
- Review every caption event against the image, not only the first and last.

## Audio

- Keep narration intelligible and phase-consistent.
- Do not normalize blindly. Compare mean and peak levels with the reference.
- Use short, low-level SFX that explain an edit: reveal chime, wipe/whoosh, application click, CTA cue.
- Prevent clipping after mixing; verify the final AAC decode.
- Re-transcribe the rendered file to catch missing, reordered, or truncated phrases.

## FFmpeg delivery pattern

Use a filter script for multi-clip timelines. Normalize each clip before concatenation:

```text
setpts → trim → fps → scale/crop → eq/color → setsar=1 → format=yuv420p
```

For a common social delivery:

```text
H.264 High, 1080×1920, 30 fps, yuv420p
AAC LC, 48 kHz, stereo, 160–192 kb/s
faststart enabled
```

Map only the intended video and audio streams. Use `-write_tmcd 0`, `-map_metadata -1`, and `-map_chapters -1` when unwanted timecode/data tracks are inherited.

## QA acceptance

Accept the delivery only when:

- Full decode returns no error.
- Duration and frame count match the narration/timing table.
- No unintended black or frozen interval is reported.
- Narration is complete and captions match it.
- Faces, hands, application areas, and product labels remain visible.
- CTA is legible and product-visible.
- Only the allowlisted footage appears.
