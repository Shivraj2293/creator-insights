import numpy as np
from scipy.stats import linregress
from typing import List

def velocity(times: List[float], counts: List[float]) -> float:
    # times: timestamps in seconds
    if len(times) < 2:
        return 0.0
    slope, _, _, _, _ = linregress(times, counts)
    return float(slope)
