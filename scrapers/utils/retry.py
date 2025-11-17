from tenacity import retry, wait_exponential, stop_after_attempt

def retry_decorator():
    return retry(wait=wait_exponential(multiplier=1, min=2, max=10), stop=stop_after_attempt(3))
