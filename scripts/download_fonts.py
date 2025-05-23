#!/usr/bin/env python3
"""
Font downloader for checklists project.
Downloads B612 font family from Google Fonts API to local fonts/ directory.
"""

import json
import os
import urllib.request
import urllib.parse
from pathlib import Path


def retrieve_webfont_family(family):
    """Retrieve font family information from Google Fonts API."""
    WEB_FONT_LIST_URL = "https://fonts.google.com/download/list?family="
    list_url = WEB_FONT_LIST_URL + urllib.parse.quote(family)
    
    try:
        with urllib.request.urlopen(list_url) as response:
            # Google Fonts API returns JSONP-style response with )]}' prefix
            data = response.read()
            # Remove the )]}' prefix
            if data.startswith(b")]}'"):
                data = data[4:]
            return json.loads(data)
    except Exception as e:
        raise Exception(f"Failed to retrieve font family {family}: {e}")


def download_font_family(family, font_dir):
    """Download all fonts for a given family."""
    print(f"Downloading {family} font family to {font_dir}...")
    
    family_data = retrieve_webfont_family(family)
    downloaded_files = []
    
    for file_ref in family_data["manifest"]["fileRefs"]:
        filename = file_ref["filename"]
        
        # Only download actual font files
        if not filename.endswith(('.ttf', '.otf')):
            continue
            
        # Only download files that contain the family name
        if family.lower() not in filename.lower():
            continue
            
        # Extract just the filename without path
        font_filename = os.path.basename(filename)
        font_path = font_dir / font_filename
        
        # Skip if already exists
        if font_path.exists():
            print(f"  {font_filename} already exists, skipping")
            downloaded_files.append(font_path)
            continue
            
        print(f"  Downloading {font_filename}...")
        try:
            urllib.request.urlretrieve(file_ref["url"], font_path)
            downloaded_files.append(font_path)
        except Exception as e:
            print(f"  Failed to download {font_filename}: {e}")
    
    return downloaded_files


def main():
    """Main function to download fonts."""
    # Use fonts/ directory relative to project root
    project_root = Path(__file__).parent.parent
    font_dir = project_root / "fonts"
    font_dir.mkdir(exist_ok=True)
    
    # Download B612 font family
    try:
        downloaded_files = download_font_family("B612", font_dir)
        
        if downloaded_files:
            print(f"\nSuccessfully downloaded {len(downloaded_files)} font files:")
            for font_path in downloaded_files:
                print(f"  {font_path.name}")
        else:
            print("No new fonts were downloaded")
            
        print(f"\nFonts are available in: {font_dir}")
        
    except Exception as e:
        print(f"Error downloading fonts: {e}")
        return 1
    
    return 0


if __name__ == "__main__":
    exit(main())
