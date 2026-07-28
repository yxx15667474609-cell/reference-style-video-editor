# Jianying Project Inspection

Use this reference only for an open Jianying/剪映/CapCut project.

## Read safely

1. Use the `computer-use` skill to inspect the active application and confirm the project title.
2. Keep the reference project read-only. Do not move clips, change effects, save, or export over an existing file during analysis.
3. Inspect the whole timeline at multiple zoom levels:
   - master duration and canvas;
   - video/audio/caption/effect track count;
   - clip boundaries and source in/out points;
   - speed curves, keyframes, masks, crop/reframe;
   - transitions, filters, overlays, stickers, and CTA elements;
   - caption presets, position, animation, and safe area;
   - music, narration, SFX, fades, and gain;
   - export settings.
4. Capture screenshots or notes at the hook, product reveal, demo, result, and CTA.

## Locate local draft data only when useful

Discover the active draft path from application state, recent files, process-open files, or filesystem search. Do not assume a fixed Jianying version-specific folder.

If draft JSON or media mappings are readable:

- Read them for exact timing and asset references.
- Resolve relative paths against the draft directory.
- Treat missing cloud/template assets as non-blocking when the finished reference video contains enough evidence.
- Never edit draft internals in place. Duplicate the project first if the user requires an editable derivative.

## Fallback

If accessibility or draft data is incomplete, analyze the exported reference video with:

- stream probing;
- uniform and beat-focused contact sheets;
- transcription with word timestamps;
- frame-by-frame inspection around cuts;
- audio peak or waveform analysis.

State whether a detail came from the live timeline or was inferred from the exported video.
