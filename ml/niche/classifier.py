import numpy as np
from sklearn.metrics.pairwise import cosine_similarity
from ..embeddings.embedder import Embedder
import json
from pathlib import Path

LABELS_PATH = Path(__file__).resolve().parent / "labels.json"

class NicheClassifier:
    def __init__(self, label_file: str | None = None):
        self.embedder = Embedder()
        self.labels = self._load_labels(label_file)

    def _load_labels(self, label_file):
        p = Path(label_file) if label_file else LABELS_PATH
        if p.exists():
            return json.loads(p.read_text())
        return ["music", "dance", "comedy", "fitness", "beauty", "gaming", "food"]

    def predict(self, text: str):
        text_emb = self.embedder.embed(text)
        label_embs = self.embedder.embed(self.labels)
        sims = cosine_similarity(text_emb.reshape(1, -1), label_embs)
        idx = int(np.argmax(sims))
        return {"label": self.labels[idx], "confidence": float(sims[0, idx])}
