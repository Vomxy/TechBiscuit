import os
import re
import shutil
import sys

POSTS_DIR = "/home/natefletcher/Documents/thetechbiscuit/content/blog"
ATTACHMENTS_DIR = "/home/natefletcher/Documents/TheTechBiscuit Vault/99 - Meta/01 - Attachments"
STATIC_IMAGES_DIR = "/home/natefletcher/Documents/thetechbiscuit/static/images/"
IMAGE_EXTENSIONS = (".webp", ".png", ".jpg", ".jpeg", ".avif")

missing_images = []
updated_files = 0
copied_files = 0

os.makedirs(STATIC_IMAGES_DIR, exist_ok=True)

for filename in os.listdir(POSTS_DIR):
    if not filename.endswith(".md"):
        continue

    filepath = os.path.join(POSTS_DIR, filename)
    with open(filepath, "r") as file:
        content = file.read()

    images = re.findall(r"\[\[([^]]+\.(?:webp|png|jpg|jpeg|avif))\]\]", content, flags=re.IGNORECASE)
    if not images:
        continue

    original_content = content

    for image in images:
        image_source = os.path.join(ATTACHMENTS_DIR, image)
        alt_text = os.path.splitext(image)[0].replace("-", " ").replace("_", " ").strip() or "Image"
        alt_text = " ".join(alt_text.split())
        markdown_image = f"![{alt_text}](/images/{image.replace(' ', '%20')})"
        content = content.replace(f"[[{image}]]", markdown_image)

        if os.path.exists(image_source):
            shutil.copy(image_source, STATIC_IMAGES_DIR)
            copied_files += 1
        else:
            missing_images.append(image)

    if content != original_content:
        with open(filepath, "w") as file:
            file.write(content)
        updated_files += 1

if missing_images:
    print("The following images were referenced but not found in attachments:")
    for image in missing_images:
        print(f"- {image}")
    sys.exit(1)

print(f"Markdown files processed: {updated_files}")
print(f"Images copied: {copied_files}")
