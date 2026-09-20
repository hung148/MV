"""Build responsive WebP assets from the selected Pexels downloads (Pillow)."""
from pathlib import Path
from PIL import Image, ImageOps
import json

ROOT = Path(__file__).resolve().parent.parent
PHOTOS = [
    ('services-milling', '28752149', 'Connor Lucock', 'industrial-drilling-process-in-a-workshop'),
    ('services-prototype', '28929513', 'Connor Lucock', 'industrial-lathe-machine-in-action'),
    ('services-production', '28752153', 'Connor Lucock', 'close-up-of-precision-machined-metal-parts'),
    ('capabilities-tooling', '50691', 'Pixabay', 'brass-and-stainless-steel-metal-tool'),
    ('about-cnc', '10406128', 'Daniel Smyth', 'close-up-photo-of-metal-tool'),
]
target = ROOT / 'assets/images/page_images'
target.mkdir(parents=True, exist_ok=True)
report = []
for name, photo_id, author, slug in PHOTOS:
    source = ROOT / f'outputs/cnc-sources/{photo_id}.jpg'
    with Image.open(source) as original:
        photo = ImageOps.exif_transpose(original).convert('RGB')
        variants = []
        for width in (480, 960, 1600):
            # Deliberate landscape crop shared by responsive candidates.
            resized = ImageOps.fit(photo, (width, width * 3 // 4), method=Image.Resampling.LANCZOS)
            output = target / f'{name}-{width}.webp'
            resized.save(output, 'WEBP', quality=78, method=6)
            variants.append({'file': output.name, 'bytes': output.stat().st_size, 'width': resized.width, 'height': resized.height})
    report.append({'name': name, 'author': author, 'source': f'https://www.pexels.com/photo/{slug}-{photo_id}/', 'license': 'https://www.pexels.com/license/', 'downloaded': '2026-09-19' if name == 'about-cnc' else '2026-09-18', 'originalBytes': source.stat().st_size, 'variants': variants})
(target / 'credits.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
(ROOT / 'functions/site/photo-credits.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
print(json.dumps(report, indent=2))
