"""
Project: TeachMe AI
Description: Flask Backend for Voice-to-Video Matching Engine.
Author: Cynthia Moraa (PLP Alumna)
Copyright (c) 2026. All Rights Reserved.

This code is proprietary. Unauthorized copying of this file is strictly prohibited.
"""


"""
TeachMe AI Backend - Python 3.13 Compatible Version
Uses Flask instead of FastAPI (no Pydantic/Rust needed)
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import logging
from datetime import datetime

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(message)s'
)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter

# ============================================================================
# YOUTUBE VIDEO DATABASE - REAL WORKING VIDEOS
# ============================================================================

VIDEO_DATABASE = {
    # PLUMBING (Maji, Mfereji, Bomba)
    "maji": {
        "video_id": "LanCLS_hIo4",
        "category": "plumbing",
        "voice_reply": "Hii hapa video ya maji na mabomba."
    },
    "mfereji": {
        "video_id": "LanCLS_hIo4",
        "category": "plumbing",
        "voice_reply": "Hii hapa video ya plumbing."
    },
    "bomba": {
        "video_id": "jI7rFpo5OZ8",
        "category": "plumbing",
        "voice_reply": "Hii hapa video ya kubadilisha mabomba."
    },
    "bafu": {
        "video_id": "LanCLS_hIo4",
        "category": "plumbing",
        "voice_reply": "Hii hapa video ya kutengeneza bafu."
    },
    "pipe": {
        "video_id": "jI7rFpo5OZ8",
        "category": "plumbing",
        "voice_reply": "Hii hapa video ya mabomba."
    },
    
    # HAIR BRAIDING (Nywele, Suka, Braids)
    "nywele": {
        "video_id": "7Y9yaOZhOLU",
        "category": "hair",
        "voice_reply": "Hii hapa video ya kusuka nywele."
    },
    "suka": {
        "video_id": "7Y9yaOZhOLU",
        "category": "hair",
        "voice_reply": "Hii hapa video ya kusuka nywele."
    },
    "braids": {
        "video_id": "YBOOXrSQpto",
        "category": "hair",
        "voice_reply": "Hii hapa video ya braids."
    },
    "cornrows": {
        "video_id": "7Y9yaOZhOLU",
        "category": "hair",
        "voice_reply": "Hii hapa video ya cornrows."
    },
    
    # FARMING (Shamba, Kilimo, Panda, Mahindi, Kuku)
    "shamba": {
        "video_id": "zISIbP3sNV0",
        "category": "farming",
        "voice_reply": "Hii hapa video ya kilimo."
    },
    "kuku": {
        "video_id": "zISIbP3sNV0",
        "category": "farming",
        "voice_reply": "Hii hapa video ya kuku na kilimo."
    },
    "kilimo": {
        "video_id": "zISIbP3sNV0",
        "category": "farming",
        "voice_reply": "Hii hapa video ya kilimo."
    },
    "panda": {
        "video_id": "KA9M6OkdLW0",
        "category": "farming",
        "voice_reply": "Hii hapa video ya kupanda mboga."
    },
    "mahindi": {
        "video_id": "d2uKyNZgbYs",
        "category": "farming",
        "voice_reply": "Hii hapa video ya kupanda mahindi."
    },
    "mboga": {
        "video_id": "KA9M6OkdLW0",
        "category": "farming",
        "voice_reply": "Hii hapa video ya mboga."
    },
    "farm": {
        "video_id": "zISIbP3sNV0",
        "category": "farming",
        "voice_reply": "Hii hapa video ya kilimo."
    },
    
    # SEWING (Shona, Nguo, Machine)
    "shona": {
        "video_id": "h5jKNGXqKWE",
        "category": "sewing",
        "voice_reply": "Hii hapa video ya kushona nguo."
    },
    "nguo": {
        "video_id": "h5jKNGXqKWE",
        "category": "sewing",
        "voice_reply": "Hii hapa video ya kushona nguo."
    },
    "machine": {
        "video_id": "aGISJGTTDJs",
        "category": "sewing",
        "voice_reply": "Hii hapa video ya kutumia machine ya kushona."
    },
    "sew": {
        "video_id": "h5jKNGXqKWE",
        "category": "sewing",
        "voice_reply": "Hii hapa video ya kushona."
    },
    
    # ELECTRICAL (Umeme, Waya, Taa)
    "umeme": {
        "video_id": "qB5yVQ4-xLU",
        "category": "electrical",
        "voice_reply": "Hii hapa video ya umeme."
    },
    "waya": {
        "video_id": "qB5yVQ4-xLU",
        "category": "electrical",
        "voice_reply": "Hii hapa video ya waya wa umeme."
    },
    "taa": {
        "video_id": "xFYwqv0vkxY",
        "category": "electrical",
        "voice_reply": "Hii hapa video ya kutengeneza taa."
    },
    "light": {
        "video_id": "xFYwqv0vkxY",
        "category": "electrical",
        "voice_reply": "Hii hapa video ya taa."
    },
    
    # CARPENTRY (Seremala, Meza, Kiti, Mbao)
    "seremala": {
        "video_id": "PE-c4PuDCAw",
        "category": "carpentry",
        "voice_reply": "Hii hapa video ya seremala."
    },
    "meza": {
        "video_id": "R9u0yb3K4f4",
        "category": "carpentry",
        "voice_reply": "Hii hapa video ya kutengeneza meza."
    },
    "kiti": {
        "video_id": "VQj9rOxWkpU",
        "category": "carpentry",
        "voice_reply": "Hii hapa video ya kutengeneza kiti."
    },
    "mbao": {
        "video_id": "PE-c4PuDCAw",
        "category": "carpentry",
        "voice_reply": "Hii hapa video ya kukata mbao."
    },
    "wood": {
        "video_id": "PE-c4PuDCAw",
        "category": "carpentry",
        "voice_reply": "Hii hapa video ya seremala."
    },
    
    # COOKING (Pika, Chakula, Ugali, Chapati)
    "pika": {
        "video_id": "FhB-IxV_rZc",
        "category": "cooking",
        "voice_reply": "Hii hapa video ya kupika."
    },
    "chakula": {
        "video_id": "FhB-IxV_rZc",
        "category": "cooking",
        "voice_reply": "Hii hapa video ya kupika chakula."
    },
    "ugali": {
        "video_id": "IrHeCwDiKoo",
        "category": "cooking",
        "voice_reply": "Hii hapa video ya kupika ugali."
    },
    "chapati": {
        "video_id": "F2hpJT_HcZI",
        "category": "cooking",
        "voice_reply": "Hii hapa video ya kupika chapati."
    },
    "cook": {
        "video_id": "FhB-IxV_rZc",
        "category": "cooking",
        "voice_reply": "Hii hapa video ya kupika."
    },
    
    # MASONRY (Jenga, Matofali, Saruji)
    "jenga": {
        "video_id": "h91D33r56uI",
        "category": "masonry",
        "voice_reply": "Hii hapa video ya ujenzi."
    },
    "matofali": {
        "video_id": "h91D33r56uI",
        "category": "masonry",
        "voice_reply": "Hii hapa video ya kupanga matofali."
    },
    "saruji": {
        "video_id": "0RdqBXQy73M",
        "category": "masonry",
        "voice_reply": "Hii hapa video ya kuchanganya saruji."
    },
    "build": {
        "video_id": "h91D33r56uI",
        "category": "masonry",
        "voice_reply": "Hii hapa video ya ujenzi."
    },
    
    # AUTO MECHANICS (Gari, Injini, Wheel)
    "gari": {
        "video_id": "WGiTeYT6HEQ",
        "category": "mechanics",
        "voice_reply": "Hii hapa video ya kutengeneza gari."
    },
    "injini": {
        "video_id": "lE4aGt-HzY8",
        "category": "mechanics",
        "voice_reply": "Hii hapa video ya injini ya gari."
    },
    "wheel": {
        "video_id": "joBmbh0AGSQ",
        "category": "mechanics",
        "voice_reply": "Hii hapa video ya magurudumu."
    },
    "car": {
        "video_id": "WGiTeYT6HEQ",
        "category": "mechanics",
        "voice_reply": "Hii hapa video ya gari."
    },
    
    # WELDING (Weld, Chuma)
    "weld": {
        "video_id": "IzQ5_rwcGwk",
        "category": "welding",
        "voice_reply": "Hii hapa video ya welding."
    },
    "chuma": {
        "video_id": "IzQ5_rwcGwk",
        "category": "welding",
        "voice_reply": "Hii hapa video ya kufanya kazi na chuma."
    },
    
    # PHONE REPAIR (Simu, Screen)
    "simu": {
        "video_id": "RiMo-HHMaBk",
        "category": "phone_repair",
        "voice_reply": "Hii hapa video ya kutengeneza simu."
    },
    "screen": {
        "video_id": "RiMo-HHMaBk",
        "category": "phone_repair",
        "voice_reply": "Hii hapa video ya kubadilisha screen ya simu."
    },
}

DEFAULT_VIDEO = {
    "video_id": "N2S1NP-gQe8",
    "category": "intro",
    "voice_reply": "Samahani, sijapata video hiyo. Hii ni video ya msingi."
}


def find_matching_video(spoken_text):
    """Find best matching video using AGGRESSIVE multiple strategies"""
    spoken_lower = spoken_text.lower().strip()
    
    logger.info(f"🎤 Processing: '{spoken_text}'")
    
    # Strategy 1: Exact match
    if spoken_lower in VIDEO_DATABASE:
        video_info = VIDEO_DATABASE[spoken_lower]
        logger.info(f"✅ Exact match: {spoken_lower} -> {video_info['video_id']}")
        return {
            "video_id": video_info["video_id"],
            "voice_reply": video_info["voice_reply"]
        }
    
    # Strategy 2: Contains keyword (AGGRESSIVE - checks if keyword appears anywhere)
    for keyword, video_info in VIDEO_DATABASE.items():
        if keyword in spoken_lower:
            logger.info(f"✅ Contains match: {keyword} -> {video_info['video_id']}")
            return {
                "video_id": video_info["video_id"],
                "voice_reply": video_info["voice_reply"]
            }
    
    # Strategy 3: Word-by-word extraction (AGGRESSIVE - removes common words)
    # Remove common Swahili and English filler words
    common_words = {
        'nataka', 'i', 'want', 'need', 'show', 'me', 'how', 'to', 'learn',
        'ya', 'wa', 'na', 'ni', 'kwa', 'na', 'au', 'the', 'a', 'an',
        'kujifunza', 'jifunze', 'onesha', 'onyesha', 'tengeneza', 'fanya'
    }
    
    words = spoken_lower.split()
    # Remove common words and clean
    meaningful_words = []
    for word in words:
        clean_word = word.strip().replace('ya', '').replace('wa', '').replace('na', '').strip()
        if len(clean_word) > 2 and clean_word not in common_words:
            meaningful_words.append(clean_word)
    
    logger.info(f"🔍 Extracted meaningful words: {meaningful_words}")
    
    # Check each meaningful word against keywords
    for keyword, video_info in VIDEO_DATABASE.items():
        for word in meaningful_words:
            # Direct match
            if keyword == word:
                logger.info(f"✅ Word match: {keyword} == {word} -> {video_info['video_id']}")
                return {
                    "video_id": video_info["video_id"],
                    "voice_reply": video_info["voice_reply"]
                }
            # Contains match (bidirectional)
            if keyword in word or word in keyword:
                if len(word) >= 3 and len(keyword) >= 3:  # Avoid false matches on short words
                    logger.info(f"✅ Partial match: {keyword} <-> {word} -> {video_info['video_id']}")
                    return {
                        "video_id": video_info["video_id"],
                        "voice_reply": video_info["voice_reply"]
                    }
    
    # Strategy 4: Fuzzy character matching (for misheard words)
    # Check if any keyword shares significant characters with spoken words
    for keyword, video_info in VIDEO_DATABASE.items():
        for word in meaningful_words:
            # Check if they share at least 60% of characters (for misheard words)
            if len(word) >= 4 and len(keyword) >= 4:
                common_chars = set(keyword) & set(word)
                similarity = len(common_chars) / max(len(set(keyword)), len(set(word)))
                if similarity >= 0.6:
                    logger.info(f"✅ Fuzzy match: {keyword} ~ {word} (similarity: {similarity:.2f}) -> {video_info['video_id']}")
                    return {
                        "video_id": video_info["video_id"],
                        "voice_reply": video_info["voice_reply"]
                    }
    
    # No match found
    logger.warning(f"⚠️ No match for: '{spoken_text}' - returning default")
    return {
        "video_id": DEFAULT_VIDEO["video_id"],
        "voice_reply": DEFAULT_VIDEO["voice_reply"]
    }


@app.route('/')
def root():
    """Health check endpoint"""
    return jsonify({
        "status": "active",
        "service": "TeachMe AI Backend",
        "version": "1.0.0",
        "keywords": len(VIDEO_DATABASE),
        "categories": len(set(v["category"] for v in VIDEO_DATABASE.values())),
        "timestamp": datetime.now().isoformat()
    })


@app.route('/process-voice', methods=['POST'])
def process_voice():
    """Main endpoint - process voice and return video"""
    data = request.get_json()
    
    if not data or 'spoken_text' not in data:
        return jsonify({"error": "Missing spoken_text"}), 400
    
    spoken_text = data['spoken_text']
    if not spoken_text or not spoken_text.strip():
        return jsonify({"error": "Empty voice input"}), 400
    
    result = find_matching_video(spoken_text)
    
    logger.info(
        f"📹 Result: {result['video_id']} | "
        f"🔊 Reply: {result['voice_reply']}"
    )
    
    return jsonify(result)


@app.route('/videos')
def list_videos():
    """Admin: List all videos"""
    videos = {}
    for keyword, info in VIDEO_DATABASE.items():
        vid = info['video_id']
        if vid not in videos:
            videos[vid] = {
                "category": info['category'],
                "keywords": [],
                "reply": info['voice_reply'],
                "url": f"https://youtube.com/watch?v={vid}"
            }
        videos[vid]["keywords"].append(keyword)
    
    return jsonify({
        "total_keywords": len(VIDEO_DATABASE),
        "unique_videos": len(videos),
        "videos": videos
    })


@app.route('/keywords')
def list_keywords():
    """Admin: List all keywords"""
    by_category = {}
    for keyword, info in VIDEO_DATABASE.items():
        cat = info['category']
        if cat not in by_category:
            by_category[cat] = []
        by_category[cat].append(keyword)
    
    return jsonify({
        "all_keywords": sorted(VIDEO_DATABASE.keys()),
        "total": len(VIDEO_DATABASE),
        "by_category": by_category
    })


@app.route('/stats')
def get_stats():
    """Admin: Get statistics"""
    categories = {}
    for info in VIDEO_DATABASE.values():
        cat = info['category']
        categories[cat] = categories.get(cat, 0) + 1
    
    return jsonify({
        "total_keywords": len(VIDEO_DATABASE),
        "unique_videos": len(set(v['video_id'] for v in VIDEO_DATABASE.values())),
        "categories": categories,
        "timestamp": datetime.now().isoformat()
    })


@app.route('/test', methods=['POST'])
def test_matching():
    """Test endpoint: See how matching works"""
    data = request.get_json()
    spoken_text = data.get('spoken_text', '')
    spoken_lower = spoken_text.lower().strip()
    
    exact = []
    contains = []
    partial = []
    
    for keyword, info in VIDEO_DATABASE.items():
        if keyword == spoken_lower:
            exact.append(keyword)
        elif keyword in spoken_lower:
            contains.append(keyword)
        else:
            words = spoken_lower.split()
            for word in words:
                clean = word.replace('ya', '').replace('wa', '').strip()
                if len(clean) > 2 and (keyword in clean or clean in keyword):
                    partial.append(keyword)
                    break
    
    return jsonify({
        "input": spoken_text,
        "exact_matches": exact,
        "contains_matches": contains,
        "partial_matches": partial,
        "final_result": find_matching_video(spoken_text)
    })


if __name__ == "__main__":
    print("=" * 80)
    print("🚀 TeachMe AI Backend Starting (Flask - Python 3.13 Compatible)")
    print(f"📚 Keywords: {len(VIDEO_DATABASE)}")
    print(f"🎬 Videos: {len(set(v['video_id'] for v in VIDEO_DATABASE.values()))}")
    print("🌍 Server: http://0.0.0.0:8000")
    print("=" * 80)
    
    app.run(host='0.0.0.0', port=8000, debug=True)