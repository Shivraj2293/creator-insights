import re
from typing import List

def extract_hashtags(text: str) -> List[str]:
    if not text:
        return []
    tags = re.findall(r"#([\\w\\-]+)", text)
    return [t.lower() for t in tags]
