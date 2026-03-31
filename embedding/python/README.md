# Embedding Skill Python SDK

This skill guides the implementation of embedding functionality using the coze-coding-dev-sdk Python package, enabling powerful vector representation capabilities for text, images, and videos.

## Skills Path

**Skill Location**: `{project_path}/skills/embedding`

This skill is located at the above path in your project.

**Reference Scripts**: Example test scripts are available in the `{Skill Location}/scripts/` directory for quick testing and reference. See `{Skill Location}/scripts/embedding.py` for a working example.

## Overview

The Embedding skill allows you to convert text, images, and videos into high-dimensional vector representations that capture semantic meaning. These embeddings can be used for:

- **Semantic Search**: Find similar documents based on meaning, not just keywords
- **Similarity Comparison**: Compare the semantic similarity between texts, images, or videos
- **Clustering**: Group similar content together
- **Recommendation Systems**: Find related content based on embeddings
- **RAG Applications**: Retrieve relevant context for LLM prompts
- **Multi-Vector Output**: Generate multiple embedding vectors for complex content
- **Sparse Embeddings**: Generate sparse vectors for hybrid search

**Default Model**: `doubao-embedding-vision-251215`

**IMPORTANT**: This SDK is designed for backend/server-side use. Always ensure proper API key management and never expose credentials in client-side code.

## Prerequisites

The coze-coding-dev-sdk package should be installed. Install it using:

```bash
pip install coze-coding-dev-sdk
```

Import it as shown in the examples below.

## Basic Text Embedding

### Single Text Embedding

```python
from coze_coding_dev_sdk import EmbeddingClient

def get_text_embedding(text: str) -> list:
    """Get embedding vector for a single text."""
    client = EmbeddingClient()
    embedding = client.embed_text(text)
    return embedding

# Usage
text = "Machine learning is transforming the world."
embedding = get_text_embedding(text)
print(f"Embedding dimension: {len(embedding)}")
print(f"First 5 values: {embedding[:5]}")
```

### Batch Text Embedding

```python
from coze_coding_dev_sdk import EmbeddingClient
from typing import List

def get_batch_embeddings(texts: List[str]) -> List[List[float]]:
    """Get embeddings for multiple texts at once."""
    client = EmbeddingClient()
    embeddings = client.embed_texts(texts)
    return embeddings

# Usage
texts = [
    "The quick brown fox jumps over the lazy dog.",
    "Machine learning is a subset of artificial intelligence.",
    "Python is a popular programming language."
]

embeddings = get_batch_embeddings(texts)
for i, (text, emb) in enumerate(zip(texts, embeddings)):
    print(f"Text {i+1}: {text[:50]}...")
    print(f"  Dimension: {len(emb)}")
```

### Custom Dimensions

```python
from coze_coding_dev_sdk import EmbeddingClient

def get_embedding_with_dimensions(text: str, dimensions: int = 512) -> list:
    """Get embedding with custom output dimensions."""
    client = EmbeddingClient()
    embedding = client.embed_text(text, dimensions=dimensions)
    return embedding

# Usage - Smaller dimension for efficiency
embedding_512 = get_embedding_with_dimensions("Sample text", dimensions=512)
print(f"512-dim embedding: {len(embedding_512)} dimensions")

# Usage - Larger dimension for accuracy
embedding_1024 = get_embedding_with_dimensions("Sample text", dimensions=1024)
print(f"1024-dim embedding: {len(embedding_1024)} dimensions")
```

## Image Embedding

### Single Image Embedding

```python
from coze_coding_dev_sdk import EmbeddingClient

def get_image_embedding(image_url: str) -> list:
    """Get embedding vector for an image."""
    client = EmbeddingClient()
    embedding = client.embed_image(image_url)
    return embedding

# Usage
image_url = "https://example.com/image.jpg"
embedding = get_image_embedding(image_url)
print(f"Image embedding dimension: {len(embedding)}")
```

### Batch Image Embedding

```python
from coze_coding_dev_sdk import EmbeddingClient
from typing import List

def get_batch_image_embeddings(image_urls: List[str]) -> List[List[float]]:
    """Get embeddings for multiple images at once."""
    client = EmbeddingClient()
    embeddings = client.embed_images(image_urls)
    return embeddings

# Usage
image_urls = [
    "https://example.com/image1.jpg",
    "https://example.com/image2.jpg",
    "https://example.com/image3.jpg"
]

embeddings = get_batch_image_embeddings(image_urls)
for i, emb in enumerate(embeddings):
    print(f"Image {i+1} embedding dimension: {len(emb)}")
```

## Multimodal Embedding

### Combined Text and Image Embedding

```python
from coze_coding_dev_sdk import EmbeddingClient

def get_multimodal_embeddings(
    texts: list = None,
    image_urls: list = None
) -> dict:
    """Get embeddings for both texts and images in a single call."""
    client = EmbeddingClient()
    response = client.embed_multimodal(
        texts=texts,
        image_urls=image_urls
    )
    return {
        "embeddings": response.embeddings,
        "model": response.model,
        "usage": response.usage
    }

# Usage
result = get_multimodal_embeddings(
    texts=["A beautiful sunset over the ocean"],
    image_urls=["https://example.com/sunset.jpg"]
)

print(f"Total embeddings: {len(result['embeddings'])}")
print(f"Model used: {result['model']}")
```

## Advanced Use Cases

### Semantic Search

```python
from coze_coding_dev_sdk import EmbeddingClient
import numpy as np
from typing import List, Tuple

class SemanticSearch:
    def __init__(self):
        self.client = EmbeddingClient()
        self.documents = []
        self.embeddings = []
    
    def add_documents(self, documents: List[str]):
        """Add documents to the search index."""
        self.documents.extend(documents)
        new_embeddings = self.client.embed_texts(documents)
        self.embeddings.extend(new_embeddings)
    
    def search(self, query: str, top_k: int = 5) -> List[Tuple[str, float]]:
        """Search for similar documents."""
        query_embedding = self.client.embed_text(query)
        
        similarities = []
        for i, doc_embedding in enumerate(self.embeddings):
            similarity = self._cosine_similarity(query_embedding, doc_embedding)
            similarities.append((self.documents[i], similarity))
        
        similarities.sort(key=lambda x: x[1], reverse=True)
        return similarities[:top_k]
    
    def _cosine_similarity(self, a: List[float], b: List[float]) -> float:
        """Calculate cosine similarity between two vectors."""
        a = np.array(a)
        b = np.array(b)
        return np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b))

# Usage
search_engine = SemanticSearch()

documents = [
    "Python is a high-level programming language.",
    "Machine learning models can predict outcomes.",
    "Deep learning uses neural networks.",
    "Natural language processing analyzes text.",
    "Computer vision processes images and videos."
]

search_engine.add_documents(documents)

results = search_engine.search("How do computers understand text?", top_k=3)
for doc, score in results:
    print(f"Score: {score:.4f} - {doc}")
```

### Document Similarity Comparison

```python
from coze_coding_dev_sdk import EmbeddingClient
import numpy as np

def compare_documents(doc1: str, doc2: str) -> float:
    """Compare semantic similarity between two documents."""
    client = EmbeddingClient()
    
    embeddings = client.embed_texts([doc1, doc2])
    emb1, emb2 = embeddings[0], embeddings[1]
    
    emb1 = np.array(emb1)
    emb2 = np.array(emb2)
    similarity = np.dot(emb1, emb2) / (np.linalg.norm(emb1) * np.linalg.norm(emb2))
    
    return float(similarity)

# Usage
doc1 = "The cat sat on the mat."
doc2 = "A feline rested on the rug."
doc3 = "The stock market crashed today."

sim_12 = compare_documents(doc1, doc2)
sim_13 = compare_documents(doc1, doc3)

print(f"Similarity between doc1 and doc2: {sim_12:.4f}")
print(f"Similarity between doc1 and doc3: {sim_13:.4f}")
```

### Text Clustering

```python
from coze_coding_dev_sdk import EmbeddingClient
from sklearn.cluster import KMeans
import numpy as np
from typing import List, Dict

def cluster_texts(texts: List[str], n_clusters: int = 3) -> Dict[int, List[str]]:
    """Cluster texts based on their embeddings."""
    client = EmbeddingClient()
    
    embeddings = client.embed_texts(texts)
    embeddings_array = np.array(embeddings)
    
    kmeans = KMeans(n_clusters=n_clusters, random_state=42)
    labels = kmeans.fit_predict(embeddings_array)
    
    clusters = {}
    for text, label in zip(texts, labels):
        if label not in clusters:
            clusters[label] = []
        clusters[label].append(text)
    
    return clusters

# Usage
texts = [
    "Python is great for data science.",
    "JavaScript powers the web.",
    "Machine learning predicts outcomes.",
    "React is a frontend framework.",
    "Deep learning uses neural networks.",
    "Vue.js is another frontend option."
]

clusters = cluster_texts(texts, n_clusters=2)
for cluster_id, cluster_texts in clusters.items():
    print(f"\nCluster {cluster_id}:")
    for text in cluster_texts:
        print(f"  - {text}")
```

### RAG Context Retrieval

```python
from coze_coding_dev_sdk import EmbeddingClient
import numpy as np
from typing import List

class RAGRetriever:
    def __init__(self, chunk_size: int = 500):
        self.client = EmbeddingClient()
        self.chunks = []
        self.embeddings = []
        self.chunk_size = chunk_size
    
    def add_document(self, document: str):
        """Add a document by splitting into chunks and embedding."""
        new_chunks = self._split_into_chunks(document)
        self.chunks.extend(new_chunks)
        
        new_embeddings = self.client.embed_texts(new_chunks)
        self.embeddings.extend(new_embeddings)
    
    def _split_into_chunks(self, text: str) -> List[str]:
        """Split text into chunks of approximately chunk_size characters."""
        words = text.split()
        chunks = []
        current_chunk = []
        current_length = 0
        
        for word in words:
            if current_length + len(word) > self.chunk_size and current_chunk:
                chunks.append(" ".join(current_chunk))
                current_chunk = [word]
                current_length = len(word)
            else:
                current_chunk.append(word)
                current_length += len(word) + 1
        
        if current_chunk:
            chunks.append(" ".join(current_chunk))
        
        return chunks
    
    def retrieve(self, query: str, top_k: int = 3) -> List[str]:
        """Retrieve most relevant chunks for a query."""
        query_embedding = self.client.embed_text(query)
        query_emb = np.array(query_embedding)
        
        similarities = []
        for i, chunk_emb in enumerate(self.embeddings):
            chunk_emb = np.array(chunk_emb)
            similarity = np.dot(query_emb, chunk_emb) / (
                np.linalg.norm(query_emb) * np.linalg.norm(chunk_emb)
            )
            similarities.append((i, similarity))
        
        similarities.sort(key=lambda x: x[1], reverse=True)
        
        return [self.chunks[i] for i, _ in similarities[:top_k]]

# Usage
retriever = RAGRetriever(chunk_size=200)

document = """
Machine learning is a subset of artificial intelligence that enables 
systems to learn and improve from experience without being explicitly 
programmed. It focuses on developing algorithms that can access data 
and use it to learn for themselves. The process begins with observations 
or data, such as examples, direct experience, or instruction, to look 
for patterns in data and make better decisions in the future.
"""

retriever.add_document(document)

query = "How do machines learn from data?"
relevant_chunks = retriever.retrieve(query, top_k=2)

print("Query:", query)
print("\nRelevant chunks:")
for i, chunk in enumerate(relevant_chunks):
    print(f"\n{i+1}. {chunk}")
```

### Async Batch Processing

```python
import asyncio
from coze_coding_dev_sdk import EmbeddingClient
from typing import List

async def process_large_dataset(texts: List[str], batch_size: int = 50):
    """Process a large dataset of texts asynchronously."""
    client = EmbeddingClient()
    
    batches = [texts[i:i + batch_size] for i in range(0, len(texts), batch_size)]
    
    results = await client.batch_embed(
        text_batches=batches,
        max_concurrent=5
    )
    
    all_embeddings = []
    for response in results:
        all_embeddings.extend(response.embeddings)
    
    return all_embeddings

# Usage
texts = [f"Sample text number {i}" for i in range(200)]

embeddings = asyncio.run(process_large_dataset(texts, batch_size=50))
print(f"Processed {len(embeddings)} embeddings")
```

## Best Practices

### 1. Batch Processing for Efficiency

```python
from coze_coding_dev_sdk import EmbeddingClient

def efficient_embedding(texts: list, batch_size: int = 50):
    """Process texts in batches for better efficiency."""
    client = EmbeddingClient()
    all_embeddings = []
    
    for i in range(0, len(texts), batch_size):
        batch = texts[i:i + batch_size]
        embeddings = client.embed_texts(batch)
        all_embeddings.extend(embeddings)
    
    return all_embeddings

# Usage
large_text_list = ["Text " + str(i) for i in range(1000)]
embeddings = efficient_embedding(large_text_list, batch_size=50)
print(f"Processed {len(embeddings)} embeddings")
```

### 2. Error Handling

```python
from coze_coding_dev_sdk import EmbeddingClient, APIError, ValidationError

def safe_embed(texts: list, retries: int = 3):
    """Embed texts with proper error handling."""
    client = EmbeddingClient()
    
    for attempt in range(1, retries + 1):
        try:
            embeddings = client.embed_texts(texts)
            return embeddings
            
        except ValidationError as e:
            print(f"Validation error: {e}")
            raise
            
        except APIError as e:
            print(f"API error (attempt {attempt}/{retries}): {e}")
            if attempt < retries:
                import time
                time.sleep(2 ** attempt)
            else:
                raise
                
        except Exception as e:
            print(f"Unexpected error (attempt {attempt}/{retries}): {e}")
            if attempt < retries:
                import time
                time.sleep(2 ** attempt)
            else:
                raise
    
    raise Exception("Failed after all retries")

# Usage
try:
    embeddings = safe_embed(["Hello world", "Test text"])
    print(f"Successfully embedded {len(embeddings)} texts")
except Exception as e:
    print(f"Failed to embed: {e}")
```

### 3. Caching Embeddings

```python
import hashlib
import json
import os
from coze_coding_dev_sdk import EmbeddingClient
from typing import List, Optional

class EmbeddingCache:
    def __init__(self, cache_dir: str = "./embedding_cache"):
        self.cache_dir = cache_dir
        self.client = EmbeddingClient()
        os.makedirs(cache_dir, exist_ok=True)
    
    def _get_cache_key(self, text: str) -> str:
        return hashlib.md5(text.encode()).hexdigest()
    
    def _get_cache_path(self, cache_key: str) -> str:
        return os.path.join(self.cache_dir, f"{cache_key}.json")
    
    def get_embedding(self, text: str, use_cache: bool = True) -> List[float]:
        cache_key = self._get_cache_key(text)
        cache_path = self._get_cache_path(cache_key)
        
        if use_cache and os.path.exists(cache_path):
            with open(cache_path, 'r') as f:
                return json.load(f)
        
        embedding = self.client.embed_text(text)
        
        with open(cache_path, 'w') as f:
            json.dump(embedding, f)
        
        return embedding

# Usage
cache = EmbeddingCache()
embedding1 = cache.get_embedding("Hello world")
embedding2 = cache.get_embedding("Hello world")
print("Second call uses cache")
```

### 4. Dimension Selection

```python
from coze_coding_dev_sdk import EmbeddingClient

def get_optimal_embedding(text: str, use_case: str = "search"):
    """Get embedding with dimensions optimized for use case."""
    client = EmbeddingClient()
    
    dimension_map = {
        "search": 1024,
        "clustering": 512,
        "classification": 768,
        "similarity": 1024,
        "storage_efficient": 256
    }
    
    dimensions = dimension_map.get(use_case, 1024)
    
    embedding = client.embed_text(text, dimensions=dimensions)
    return embedding

# Usage
search_embedding = get_optimal_embedding("Sample text", use_case="search")
print(f"Search embedding: {len(search_embedding)} dimensions")

efficient_embedding = get_optimal_embedding("Sample text", use_case="storage_efficient")
print(f"Storage-efficient embedding: {len(efficient_embedding)} dimensions")
```

## Integration Examples

### Flask API Endpoint

```python
from flask import Flask, request, jsonify
from coze_coding_dev_sdk import EmbeddingClient, APIError

app = Flask(__name__)
client = EmbeddingClient()

@app.route('/api/embed', methods=['POST'])
def embed_text():
    try:
        data = request.get_json()
        texts = data.get('texts', [])
        dimensions = data.get('dimensions')
        
        if not texts:
            return jsonify({'error': 'texts is required'}), 400
        
        if isinstance(texts, str):
            texts = [texts]
        
        embeddings = client.embed_texts(texts, dimensions=dimensions)
        
        return jsonify({
            'success': True,
            'embeddings': embeddings,
            'count': len(embeddings),
            'dimensions': len(embeddings[0]) if embeddings else 0
        })
        
    except APIError as e:
        return jsonify({'error': str(e)}), 500
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/similarity', methods=['POST'])
def calculate_similarity():
    try:
        data = request.get_json()
        text1 = data.get('text1')
        text2 = data.get('text2')
        
        if not text1 or not text2:
            return jsonify({'error': 'text1 and text2 are required'}), 400
        
        embeddings = client.embed_texts([text1, text2])
        
        import numpy as np
        emb1 = np.array(embeddings[0])
        emb2 = np.array(embeddings[1])
        similarity = float(np.dot(emb1, emb2) / (np.linalg.norm(emb1) * np.linalg.norm(emb2)))
        
        return jsonify({
            'success': True,
            'similarity': similarity
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, port=5000)
```

### FastAPI Implementation

```python
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from typing import List, Optional
from coze_coding_dev_sdk import EmbeddingClient, APIError
import numpy as np

app = FastAPI(title="Embedding API")
client = EmbeddingClient()

class EmbedRequest(BaseModel):
    texts: List[str] = Field(..., description="List of texts to embed")
    dimensions: Optional[int] = Field(None, description="Output dimensions")

class SimilarityRequest(BaseModel):
    text1: str = Field(..., description="First text")
    text2: str = Field(..., description="Second text")

class SearchRequest(BaseModel):
    query: str = Field(..., description="Search query")
    documents: List[str] = Field(..., description="Documents to search")
    top_k: int = Field(default=5, description="Number of results")

@app.post("/api/embed")
async def embed_texts(request: EmbedRequest):
    try:
        embeddings = client.embed_texts(
            request.texts,
            dimensions=request.dimensions
        )
        
        return {
            "success": True,
            "embeddings": embeddings,
            "count": len(embeddings),
            "dimensions": len(embeddings[0]) if embeddings else 0
        }
    except APIError as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/similarity")
async def calculate_similarity(request: SimilarityRequest):
    try:
        embeddings = client.embed_texts([request.text1, request.text2])
        
        emb1 = np.array(embeddings[0])
        emb2 = np.array(embeddings[1])
        similarity = float(np.dot(emb1, emb2) / (np.linalg.norm(emb1) * np.linalg.norm(emb2)))
        
        return {
            "success": True,
            "similarity": similarity
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/search")
async def semantic_search(request: SearchRequest):
    try:
        all_texts = [request.query] + request.documents
        embeddings = client.embed_texts(all_texts)
        
        query_emb = np.array(embeddings[0])
        doc_embeddings = [np.array(e) for e in embeddings[1:]]
        
        similarities = []
        for i, doc_emb in enumerate(doc_embeddings):
            sim = float(np.dot(query_emb, doc_emb) / (np.linalg.norm(query_emb) * np.linalg.norm(doc_emb)))
            similarities.append((request.documents[i], sim))
        
        similarities.sort(key=lambda x: x[1], reverse=True)
        
        return {
            "success": True,
            "results": [
                {"document": doc, "score": score}
                for doc, score in similarities[:request.top_k]
            ]
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

## Troubleshooting

### Issue: Empty or invalid input

**Error Message**: `At least one of texts or image_urls must be provided`

**Solution**: Ensure you provide at least one non-empty text or image URL.

```python
from coze_coding_dev_sdk import EmbeddingClient

client = EmbeddingClient()

texts = ["Valid text"]
embeddings = client.embed_texts(texts)
```

### Issue: Batch size exceeded

**Error Message**: `Total inputs exceed maximum batch size of 100`

**Solution**: Split your inputs into smaller batches.

```python
from coze_coding_dev_sdk import EmbeddingClient

client = EmbeddingClient()

large_list = ["text"] * 200
batch_size = 50

all_embeddings = []
for i in range(0, len(large_list), batch_size):
    batch = large_list[i:i + batch_size]
    embeddings = client.embed_texts(batch)
    all_embeddings.extend(embeddings)
```

### Issue: API authentication failed

**Error Message**: Authentication error

**Solution**: Ensure `COZE_WORKLOAD_IDENTITY_API_KEY` environment variable is set correctly.

```python
import os

api_key = os.getenv("COZE_WORKLOAD_IDENTITY_API_KEY")
if not api_key:
    raise Exception("COZE_WORKLOAD_IDENTITY_API_KEY not set")
```

### Issue: Network timeout

**Error Message**: Connection timeout or network error

**Solution**: Implement retry logic with exponential backoff.

```python
from coze_coding_dev_sdk import EmbeddingClient
import time

def embed_with_retry(texts, max_retries=3):
    client = EmbeddingClient()
    
    for attempt in range(max_retries):
        try:
            return client.embed_texts(texts)
        except Exception as e:
            if attempt < max_retries - 1:
                wait_time = 2 ** attempt
                print(f"Retry {attempt + 1}/{max_retries} after {wait_time}s")
                time.sleep(wait_time)
            else:
                raise

embeddings = embed_with_retry(["Hello world"])
```

## Supported Models

- `doubao-embedding-large-text-240915` (Default) - High-quality text embeddings
- Additional multimodal embedding models for text + image

## API Reference Summary

### EmbeddingClient

```python
from coze_coding_dev_sdk import EmbeddingClient

client = EmbeddingClient()

embedding = client.embed_text(text: str, model: str = None, dimensions: int = None)

embeddings = client.embed_texts(texts: List[str], model: str = None, dimensions: int = None)

embedding = client.embed_image(image_url: str, model: str = None, dimensions: int = None)

embeddings = client.embed_images(image_urls: List[str], model: str = None, dimensions: int = None)

response = client.embed_multimodal(
    texts: List[str] = None,
    image_urls: List[str] = None,
    model: str = None,
    dimensions: int = None
)

response = await client.embed_async(
    texts: List[str] = None,
    image_urls: List[str] = None,
    model: str = None,
    dimensions: int = None
)

responses = await client.batch_embed(
    text_batches: List[List[str]],
    model: str = None,
    dimensions: int = None,
    max_concurrent: int = 5
)
```

### EmbeddingResponse

```python
response.success
response.embeddings
response.first_embedding
response.model
response.usage
response.error_message
```

### EmbeddingConfig

```python
from coze_coding_dev_sdk import EmbeddingConfig

EmbeddingConfig.DEFAULT_MODEL
EmbeddingConfig.DEFAULT_ENCODING_FORMAT
EmbeddingConfig.MAX_BATCH_SIZE
```

## Remember

- **Backend Only**: Never call these APIs from the frontend
- **Batch Processing**: Use batch methods for multiple texts to improve efficiency
- **Max Batch Size**: Maximum 100 inputs per request
- **Caching**: Consider caching embeddings for repeated texts to save costs
- **Dimensions**: Use smaller dimensions for storage efficiency, larger for accuracy
- **Error Handling**: Always implement proper error handling and retry logic
- **Environment Variables**: Set `COZE_WORKLOAD_IDENTITY_API_KEY` before using the SDK
- **Similarity Calculation**: Use cosine similarity for comparing embeddings
- **Normalization**: Embeddings are typically normalized, but verify for your use case