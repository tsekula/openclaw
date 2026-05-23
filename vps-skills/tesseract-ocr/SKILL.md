---
name: tesseract-ocr
description: Extract text from images using Tesseract OCR engine.
homepage: https://github.com/tesseract-ocr/tesseract
metadata:
  {
    "openclaw":
      {
        "emoji": "🔍",
        "requires": { "bins": ["tesseract"] },
      },
  }
---

# tesseract-ocr

Use `tesseract` to extract text from images.

Common commands

- Extract to stdout: `tesseract image.png stdout`
- Specify language: `tesseract image.png stdout -l eng`
- Save to file: `tesseract image.png output` (writes output.txt)
- List installed languages: `tesseract --list-langs`

Notes

- Only the English language pack (`eng`) is installed. To add others, extend `OPENCLAW_DOCKER_APT_PACKAGES` in `.env` (e.g. `tesseract-ocr tesseract-ocr-fra tesseract-ocr-deu`) and rebuild.
- OCR accuracy depends on image quality. Clear, high-contrast images give the best results.
- Input images should ideally be at least 300 DPI for accurate recognition.
