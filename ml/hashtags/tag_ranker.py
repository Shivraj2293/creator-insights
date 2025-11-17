from collections import Counter
import math
from typing import List, Dict

def score_hashtags(history: List[Dict]) -> Dict[str, float]:
    """
    history: list of { 'tag': 'x', 'count': int, 'engagement': float, 'timestamp': 'ISO' }
    returns tag -> score
    """
    agg = {}
    for item in history:
        t = item['tag']
        agg.setdefault(t, {'count':0, 'eng':0.0})
        agg[t]['count'] += item.get('count', 1)
        agg[t]['eng'] += item.get('engagement', 0.0)

    scores = {}
    for k,v in agg.items():
        # simple scoring: engagement weighted by sqrt(count)
        scores[k] = v['eng'] * math.sqrt(v['count'] + 1)
    return scores
