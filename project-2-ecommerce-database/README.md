<p align="center">
  <img src="docs/banner.png" alt="AI-Ready E-Commerce Platform Banner" width="700" />
</p>

<h1 align="center">🛒 AI-Ready E-Commerce Data Platform</h1>

<h3 align="center">A Production-Grade PostgreSQL System with Vector Intelligence</h3>

<p align="center">
  <img src="https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white" />
  <img src="https://img.shields.io/badge/pgvector-FF6F00?style=for-the-badge" />
  <img src="https://img.shields.io/badge/15M%2B%20Records-blue?style=for-the-badge" />
  <img src="https://img.shields.io/badge/30%20Tables-green?style=for-the-badge" />
  <img src="https://img.shields.io/badge/JSONB-orange?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Full--Text%20Search-red?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Vector%20AI-purple?style=for-the-badge" />
</p>

<p align="center">
  A complete e-commerce data platform modeled on <strong>Amazon/Flipkart-scale architecture</strong> — <br/>
  from user registration to AI-powered product recommendations — built entirely in <strong>PostgreSQL</strong>.<br/>
  Integrates <strong>pgvector</strong> for semantic search, <strong>JSONB</strong> for semi-structured data,<br/>
  <strong>full-text search</strong> for keyword matching, and <strong>materialized views</strong> for real-time dashboards.
</p>

---

## ⚡ Feature Highlights

<table>
  <tr>
    <td align="center">🏗️<br/><strong>30 Normalized Tables</strong><br/><sub>Full referential integrity with ENUMs, CHECK, UNIQUE, FK constraints</sub></td>
    <td align="center">📦<br/><strong>15M+ Synthetic Records</strong><br/><sub>1M users, 200K products, 2M orders, 5M order items</sub></td>
    <td align="center">🧠<br/><strong>AI Intelligence Layer</strong><br/><sub>pgvector embeddings, hybrid search, taste-profile recommendations</sub></td>
  </tr>
  <tr>
    <td align="center">⚡<br/><strong>Performance Engineered</strong><br/><sub>B-Tree, GIN, IVFFLAT indexes + table partitioning</sub></td>
    <td align="center">🔧<br/><strong>6 Automated Triggers</strong><br/><sub>Auto-timestamps, inventory deduction, stock validation</sub></td>
    <td align="center">📊<br/><strong>4 Materialized Views</strong><br/><sub>Pre-computed dashboards with concurrent refresh</sub></td>
  </tr>
</table>

---

## 🏛️ System Architecture & Data Flow

This platform implements a **layered data architecture** typical of production e-commerce systems, blending traditional relational processing with modern vector AI capabilities.

```mermaid
flowchart TD
    %% Cinematic Styling
    classDef core fill:#0f172a,stroke:#38bdf8,stroke-width:2px,color:#fff,shadow:shadow
    classDef ai fill:#312e81,stroke:#a855f7,stroke-width:2px,color:#fff,shadow:shadow
    classDef db fill:#064e3b,stroke:#34d399,stroke-width:2px,color:#fff,shadow:shadow
    classDef analytics fill:#7f1d1d,stroke:#f87171,stroke-width:2px,color:#fff,shadow:shadow
    classDef user fill:#1e293b,stroke:#cbd5e1,stroke-width:2px,color:#fff,shadow:shadow

    %% User Interaction Layer
    subgraph UI [📱 Client Interaction]
        direction LR
        U((👤 User)):::user -->|Searches| S[🔍 Semantic Search]:::user
        U -->|Browses| V[👀 Product Views]:::user
        U -->|Buys| C[🛒 Checkout]:::user
    end

    %% Application Logic
    subgraph Logic [⚙️ Application API]
        S -->|Query| Q_Parser[🔤 Query Parser]:::core
        V -->|Log Event| E_Engine[📡 Event Pipeline]:::core
        C -->|Process| O_Engine[💳 Order Engine]:::core
    end

    %% Database Core Layer
    subgraph DB [🗄️ Core PostgreSQL Database]
        direction TB
        Q_Parser -->|Keyword Match| FTS[(tsvector Search)]:::db
        O_Engine -->|Insert| Orders[(Orders Table\nPartitioned)]:::db
        O_Engine -->|Trigger| Inv_Trigger[⚡ Auto-Deduct Stock]:::db
        Inv_Trigger --> Inventory[(Inventory)]:::db
        E_Engine -->|JSONB| Events[(System Events)]:::analytics
    end

    %% AI Intelligence Layer
    subgraph AI [🧠 pgvector AI Layer]
        direction TB
        Q_Parser -.->|Generate Vector| Q_Vec[Array Query Vector]:::ai
        Q_Vec -.->|Cosine Distance <->| Prod_Vec[(Products Table\nvector: 384-dim)]:::ai
        FTS -.->|Combine ts_rank| Hybrid[🤖 Hybrid Search Engine]:::ai
        Prod_Vec -.->|Combine similarity| Hybrid
        
        Orders -->|Purchase History| Taste[👤 User Taste Profile]:::ai
        Taste -->|"Centroid AVG"| Prod_Vec
    end

    %% Analytics Layer
    subgraph Analytics [📊 Analytics & BI Dashboards]
        Orders -->|pg_cron| MV_LTV[(User LTV View)]:::analytics
        Orders -->|pg_cron| MV_Rev[(Seller Revenue View)]:::analytics
        Events -->|Funnel| DashBoards([👨‍💼 Admin Dashboards]):::user
        MV_LTV -->|Metrics| DashBoards
        MV_Rev -->|Metrics| DashBoards
    end

    %% Cross-layer connections
    Hybrid ==>|Results| U
    Taste ==>|Recommendations| U

    %% Styling linkages
    linkStyle default stroke:#64748b,stroke-width:2px,fill:none
```

---

## 🧠 What You Will Learn

| # | Skill Area | What You'll Master |
|:-:|:-----------|:-------------------|
| 1 | 🏗️ **Schema Design** | Normalized relational modeling across 30 interconnected tables |
| 2 | 🔐 **Constraints & Integrity** | ENUMs, CHECK, UNIQUE, FK with ON DELETE policies |
| 3 | 📦 **Large-Scale Data Generation** | `generate_series()`, `RANDOM()`, JSONB builders for 15M+ rows |
| 4 | 🔗 **Multi-Table JOINs** | Complex 3–5 table JOIN chains for analytics |
| 5 | 📊 **Window Functions** | `RANK()`, `ROW_NUMBER()`, `SUM() OVER()`, running totals |
| 6 | ⚡ **Performance Engineering** | B-Tree, GIN, IVFFLAT indexes + table partitioning |
| 7 | 🔧 **Database Automation** | Triggers for timestamps, inventory, order totals |
| 8 | 📈 **Materialized Views** | Pre-computed dashboards with concurrent refresh |
| 9 | 📝 **JSONB Operations** | Semi-structured data storage and GIN-indexed queries |
| 10 | 🔍 **Full-Text Search** | tsvector, ts_rank, GIN indexes for keyword matching |
| 11 | 🧠 **Vector Embeddings** | pgvector, cosine distance, IVFFLAT/HNSW indexing |
| 12 | 🤖 **Hybrid Search** | Combining semantic similarity + keyword relevance |
| 13 | 🎯 **Recommendation Systems** | User taste profiles, collaborative filtering, centroid search |

---

## 🗄️ Database Schema Breakdown

### Core Business Domain

<details>
<summary>👤 <strong>User System</strong> — 3 tables</summary>

<br/>

| Table | Purpose |
|:------|:--------|
| `users` | 1M user accounts with email, phone, soft-delete support |
| `user_addresses` | Shipping/billing addresses (multi-per-user) |
| `user_sessions` | Login/logout tracking for activity analysis |

```sql
CREATE TABLE users (
    user_id    BIGSERIAL PRIMARY KEY,
    full_name  TEXT NOT NULL,
    email      TEXT UNIQUE NOT NULL,
    phone      TEXT UNIQUE,
    is_active  BOOLEAN DEFAULT TRUE,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP  -- auto-maintained by trigger
);
```

</details>

<details>
<summary>🏪 <strong>Seller System</strong> — 2 tables</summary>

<br/>

| Table | Purpose |
|:------|:--------|
| `sellers` | 2K seller accounts with ratings |
| `seller_addresses` | Seller warehouse/office locations |

</details>

<details>
<summary>📦 <strong>Product Catalog</strong> — 5 tables + AI columns</summary>

<br/>

| Table | Purpose |
|:------|:--------|
| `products` | 200K products with `vector(384)` embedding + `tsvector` search |
| `product_images` | Product image URLs |
| `product_attributes` | Key-value attributes (color, size, etc.) |
| `product_tags` | Searchable tags (popular, sale, new-arrival) |
| `product_metadata` | JSONB semi-structured data (brand, weight, warranty) |

The `products` table is the AI hub — it contains both the `embedding vector(384)` column for semantic search and the `search_vector tsvector` column for full-text search.

</details>

<details>
<summary>🛒 <strong>Cart → Order → Payment → Shipping</strong> — 9 tables</summary>

<br/>

| Table | Purpose |
|:------|:--------|
| `carts` | One cart per user (auto-created via trigger) |
| `cart_items` | Products in active carts |
| `orders` | 2M orders (**partitioned by year**) |
| `order_items` | 5M line items with quantity and price |
| `payments` | Payment records (card, UPI, wallet, net_banking) |
| `refunds` | ~5% refund rate with reason tracking |
| `shipments` | Fulfillment from 20 warehouses |
| `shipment_tracking` | Location-based delivery tracking |

</details>

<details>
<summary>⭐ <strong>Review System</strong> — 2 tables</summary>

<br/>

| Table | Purpose |
|:------|:--------|
| `reviews` | 500K reviews with 1–5 star ratings |
| `review_votes` | 800K helpful/not_helpful review votes |

</details>

<details>
<summary>🏭 <strong>Inventory & Warehouse</strong> — 3 tables</summary>

<br/>

| Table | Purpose |
|:------|:--------|
| `warehouses` | 20 warehouse locations |
| `inventory` | Stock levels per product-warehouse pair |
| `inventory_movements` | 1M movement audit logs (restock/sale) |

</details>

### Analytics & AI Layer

<details>
<summary>📊 <strong>Event Tracking</strong> — 3 tables</summary>

<br/>

| Table | Purpose |
|:------|:--------|
| `product_views` | 3M view events for popularity analysis |
| `search_logs` | 2M search queries (phone, laptop, headphones...) |
| `system_events` | 2M events (**partitioned by year**) with JSONB payload |

</details>

<details>
<summary>🧠 <strong>Feature Store / AI Tables</strong> — 5 tables</summary>

<br/>

| Table | Purpose |
|:------|:--------|
| `user_features` | Pre-computed: total orders, spend, avg value, fav category |
| `product_features` | Pre-computed: popularity, avg rating, total sales |
| `product_relationships` | 500K co-purchase/similarity pairs |
| `product_metrics_daily` | Daily views, purchases, revenue per product |
| `user_recommendations` | Pre-computed recommendation cache |

These tables act as a **feature store** — pre-computed signals that feed the AI recommendation engine.

</details>

---

## 📊 Dataset Scale

| Table | Records | Description |
|:------|--------:|:------------|
| `users` | **1,000,000** | Full user roster with unique emails & phones |
| `orders` | **2,000,000** | Partitioned by year (2024–2026) |
| `order_items` | **~5,000,000** | Line-level order details |
| `product_views` | **3,000,000** | User browsing behavior |
| `system_events` | **2,000,000** | JSONB event payloads, partitioned |
| `search_logs` | **2,000,000** | Keyword search analytics |
| `inventory_movements` | **1,000,000** | Stock audit trail |
| `user_recommendations` | **1,000,000** | Pre-computed recommendation cache |
| `reviews` | **500,000** | Star ratings + text reviews |
| `review_votes` | **800,000** | Community review voting |
| `product_relationships` | **500,000** | Co-purchase & similarity pairs |
| `products` | **200,000** | With vector(384) embeddings + tsvector |
| **Total** | **~15,000,000+** | |

---

## ⚙️ Advanced PostgreSQL Features

### 📇 Indexing Strategy

| Index Type | Used For | Example |
|:-----------|:---------|:--------|
| **B-Tree** | Equality/range lookups, FK joins | `idx_orders_user ON orders(user_id)` |
| **Partial** | Hot-path queries (only matching rows) | `idx_orders_pending WHERE order_status = 'pending'` |
| **Composite** | Multi-column filtering | `idx_products_category_price ON products(category_id, price)` |
| **GIN** | JSONB containment, full-text search | `idx_metadata_json USING GIN(metadata)` |
| **IVFFLAT** | Vector similarity (cosine distance) | `idx_products_embedding USING ivfflat (embedding vector_cosine_ops)` |

### 📂 Table Partitioning

```sql
-- Orders partitioned by year (range partitioning)
CREATE TABLE orders (...) PARTITION BY RANGE (order_date);

CREATE TABLE orders_2024 PARTITION OF orders
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');
```

**Why partition?** With 2M+ orders, PostgreSQL can skip entire year-partitions during date-range queries — scanning only 1/3 of the data.

### 🔧 Triggers (6 Automated Functions)

| Trigger | Event | What It Does |
|:--------|:------|:-------------|
| `trg_users_timestamp` | `BEFORE UPDATE` | Auto-sets `updated_at` |
| `trg_user_defaults` | `AFTER INSERT ON users` | Auto-creates user cart |
| `trg_inventory_deduct` | `AFTER INSERT ON order_items` | Auto-deducts stock + logs movement |
| `trg_order_total` | `AFTER INSERT ON order_items` | Recalculates order total |
| `trg_no_negative_stock` | `BEFORE UPDATE ON inventory` | Prevents negative stock |
| `trg_products_search_vector` | `BEFORE INSERT/UPDATE` | Auto-maintains tsvector |

### 📈 Materialized Views (4 Dashboards)

| View | Pre-Computes |
|:-----|:-------------|
| `mv_seller_revenue` | Revenue + order count per seller |
| `mv_product_stats` | Units sold, revenue, avg rating per product |
| `mv_category_revenue` | Revenue + product count per category |
| `mv_user_ltv` | Lifetime value, order count, first/last order per user |

All views have `UNIQUE` indexes for `REFRESH MATERIALIZED VIEW CONCURRENTLY` support.

---

## 🧠 AI & Data Intelligence Layer ⭐

## 🧠 AI & Data Intelligence Layer ⭐

This is what separates this project from typical SQL practice databases. By bringing the **AI directly into the database**, we eliminate the need for complex external microservices and data pipelines. 

### How Traditional SQL and AI Work Together

Think of traditional SQL as a **highly-organized librarian**. If you ask for a book with "Smartphone" in the title, it instantly checks the index and gives you exactly what you asked for. It's perfectly accurate, but taking things *too literally*. If you ask for a "mobile communication device", the traditional SQL librarian will return zero results because those exact words aren't in the title.

**AI Embeddings act as a mind reader.** They don't look at words; they look at **meaning**. 
When an AI looks at "mobile communication device", it translates those words into a string of 384 numbers (a vector). It then looks at the database and finds products that have similar math coordinates. It realizes that a "smartphone" lives in the exact same mathematical neighborhood as a "mobile communication device."

**The Magic:** By combining both in PostgreSQL, we get the absolute truth and speed of the SQL librarian, combined with the context and intuition of the AI.

### What is pgvector?

[pgvector](https://github.com/pgvector/pgvector) is a PostgreSQL extension that adds a native `vector` data type and distance operators. Instead of storing just numbers or text, we can store a product's "brain profile" directly in a column.

Every product has a `vector(384)` column (compatible with MiniLM-class embedding models) that encodes the **meaning** of that product.

### Vector Similarity Search (Semantic Search)

When a user searches, we don't just use `LIKE '%keyword%'`. We use vector math to find the closest match in meaning.

```sql
-- Find the 10 most similar products to product_id = 1
SELECT product_id, product_name,
    ROUND((1 - (p1.embedding <-> p2.embedding))::NUMERIC, 4) AS similarity
FROM products p1
JOIN products p2 ON p1.product_id <> p2.product_id
WHERE p1.product_id = 1
ORDER BY p1.embedding <-> p2.embedding
LIMIT 10;
```

> **How it works:** The `<->` operator computes the "cosine distance" between two vectors. If the distance is small (close to 0), the concepts are practically identical. If it's large, they are unrelated. We order by this distance to put the best matches at the top.

### Hybrid Search (The Ultimate Combo)

Relying *only* on AI can sometimes cause hallucinations (matching a phone case when the user wants an actual phone). Relying *only* on text causes zero-results. 
**We combine them.** We give 70% weight to the AI's intuition (semantic), and 30% weight to the SQL librarian's exact keyword matches (`ts_rank`).

```sql
-- 70% semantic + 30% keyword relevance
SELECT product_name,
    0.7 * (1 - (embedding <-> query_embedding)) +
    0.3 * ts_rank(search_vector, to_tsquery('phone'))
    AS hybrid_score
FROM products
WHERE search_vector @@ to_tsquery('phone')
ORDER BY hybrid_score DESC LIMIT 10;
```

This is the exact same algorithmic foundation used by modern search engines like Google and Amazon.

### User "Taste Profile" Recommendations

How does Netflix or Spotify know what you like? They build a **taste profile**. We do this purely in SQL using vector averages.

```sql
-- Step 1: Find all products a user has purchased
-- Step 2: Average their vectors together to create a single "Taste Vector"
-- Step 3: Find new products that are mathematically close to that Taste Vector
WITH user_embedding AS (
    SELECT AVG(p.embedding) AS taste_vector
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    WHERE o.user_id = 100
)
SELECT p.product_name, 1 - (p.embedding <-> taste_vector) AS score
FROM products p, user_embedding
ORDER BY p.embedding <-> taste_vector
LIMIT 10;
```

> **How it works:** If you buy 3 Sci-Fi movies, we take the vectors for those 3 movies and use the `AVG()` SQL function on them. This creates a "center point" (centroid) in the vector space representing your personal taste. We then retrieve items closest to that center point!

### Event Tracking System

The `system_events` table (JSONB payload, partitioned by year) captures:
- `view` — product view events
- `cart` — add-to-cart events
- `purchase` — purchase events

This enables conversion funnel analysis and behavior-driven recommendations.

---

## 🔑 Key Concepts Explained

<details>
<summary>📖 <strong>Click to expand — Progressive concept guide</strong></summary>

<br/>

| Concept | Level | What It Does |
|:--------|:------|:-------------|
| `PRIMARY KEY` | Beginner | Unique row identifier |
| `FOREIGN KEY` | Beginner | Enforces referential integrity between tables |
| `NOT NULL / UNIQUE` | Beginner | Required and unique fields |
| `CHECK` | Beginner | Domain validation (`price > 0`, `rating BETWEEN 1 AND 5`) |
| `ENUM` | Intermediate | Type-safe status values (order_status, payment_status) |
| `INDEX (B-Tree)` | Intermediate | Speeds up WHERE, JOIN, ORDER BY on specific columns |
| `PARTIAL INDEX` | Intermediate | Indexes only rows matching a condition |
| `TRIGGER` | Intermediate | Auto-execute functions on INSERT/UPDATE/DELETE |
| `JSONB` | Intermediate | Flexible semi-structured data with GIN indexing |
| `tsvector / ts_rank` | Advanced | Full-text search with relevance ranking |
| `TABLE PARTITIONING` | Advanced | Split large tables by range for query pruning |
| `MATERIALIZED VIEW` | Advanced | Pre-computed query results with concurrent refresh |
| `GIN INDEX` | Advanced | Inverted index for JSONB, full-text, and arrays |
| `vector(N)` | Expert | N-dimensional embedding storage (pgvector) |
| `<->` operator | Expert | Cosine distance between vectors |
| `IVFFLAT INDEX` | Expert | Approximate nearest neighbor for vector search |
| `AVG(embedding)` | Expert | Compute centroid of multiple vectors for taste profiles |

</details>

---

## 🚀 Getting Started

### ✅ Prerequisites

| Requirement | Details |
|:---|:---|
| 🐘 **PostgreSQL** | Version 15+ (for best pgvector support) |
| 🧠 **pgvector** | Install via `apt install postgresql-15-pgvector` or from source |
| 💻 **SQL Client** | `psql`, pgAdmin, DBeaver, TablePlus, DataGrip |

> 📥 [Download PostgreSQL](https://www.postgresql.org/download/) · [Install pgvector](https://github.com/pgvector/pgvector#installation)

---

### 📦 Step 1 — Clone the Repository

```bash
git clone https://github.com/aman-bhaskar-codes/sql-data-systems-projects.git
cd sql-data-systems-projects/project-2-ecommerce-database
```

### 🗄️ Step 2 — Create Database & Extensions

```bash
psql -U postgres -f setup_database.sql
psql -U postgres -d ecommerce_platform -c "CREATE EXTENSION IF NOT EXISTS vector;"
```

### 🏗️ Step 3 — Create Schema (30 Tables)

```bash
psql -U postgres -d ecommerce_platform -f schema.sql
```

> ⚠️ The `schema.sql` file natively builds high-volume tables (`orders`, `system_events`) as **range-partitioned tables** for performance.

### 🔧 Step 4 — Install Triggers

```bash
psql -U postgres -d ecommerce_platform -f triggers.sql
```

### ⚡ Step 5 — Create Indexes

```bash
psql -U postgres -d ecommerce_platform -f indexes.sql
```

### 🌱 Step 6 — Seed the Dataset

```bash
psql -U postgres -d ecommerce_platform -f seed.sql
```

> ⏱️ This generates **15M+ records** including vector embeddings. Expect **several minutes** of execution time.

### 📊 Step 7 — Create Materialized Views

```bash
psql -U postgres -d ecommerce_platform -f materialized_views.sql
```

### 🔍 Step 8 — Run Analytics

```bash
psql -U postgres -d ecommerce_platform -f analytics.sql
```

### 🧠 Step 9 — Run AI Queries

```bash
psql -U postgres -d ecommerce_platform -f ai_queries.sql
```

---

## 🔍 Example Queries

### Revenue Analytics

<details>
<summary>🏆 <strong>Top Revenue Products</strong></summary>

```sql
SELECT p.product_name,
    SUM(oi.quantity * oi.price) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_revenue DESC
LIMIT 10;
```

</details>

### Business Intelligence

<details>
<summary>📈 <strong>Conversion Funnel (Views → Cart → Purchase)</strong></summary>

```sql
SELECT
    COUNT(*) FILTER (WHERE event_type = 'view') AS views,
    COUNT(*) FILTER (WHERE event_type = 'cart') AS carts,
    COUNT(*) FILTER (WHERE event_type = 'purchase') AS purchases,
    ROUND(
        COUNT(*) FILTER (WHERE event_type = 'purchase')::NUMERIC /
        NULLIF(COUNT(*) FILTER (WHERE event_type = 'view'), 0) * 100, 2
    ) AS conversion_rate_pct
FROM system_events;
```

</details>

### AI / Vector Queries

<details>
<summary>🧠 <strong>Hybrid Search (Semantic + Keyword)</strong></summary>

```sql
WITH query_embedding AS (
    SELECT embedding FROM products WHERE product_id = 100
)
SELECT p.product_name,
    ROUND((0.7 * (1 - (p.embedding <-> q.embedding)) +
           0.3 * ts_rank(p.search_vector, to_tsquery('phone')))::NUMERIC, 4)
        AS hybrid_score
FROM products p, query_embedding q
WHERE p.search_vector @@ to_tsquery('phone')
ORDER BY hybrid_score DESC LIMIT 10;
```

</details>

<details>
<summary>🎯 <strong>User Taste-Profile Recommendations</strong></summary>

```sql
WITH user_embedding AS (
    SELECT AVG(p.embedding) AS taste_vector
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    WHERE o.user_id = 100
)
SELECT p.product_name,
    ROUND((1 - (p.embedding <-> ue.taste_vector))::NUMERIC, 4) AS score
FROM products p, user_embedding ue
ORDER BY p.embedding <-> ue.taste_vector
LIMIT 10;
```

</details>

---

## 📏 Scaling Strategy

| Challenge | Solution | How It Works |
|:----------|:---------|:-------------|
| **Millions of rows** | Table partitioning | Orders partitioned by year, events pruned by date range |
| **Slow JOINs** | Targeted B-Tree indexes | Indexes on every FK column used in joins |
| **JSONB filtering** | GIN indexes | `@>` containment checks in O(1) via inverted index |
| **Full-text search** | tsvector + GIN | Pre-computed document vectors with ranked results |
| **Vector search** | IVFFLAT index | Approximate nearest neighbor — sub-linear time |
| **Dashboard latency** | Materialized views | Pre-computed aggregations, refreshed periodically |
| **Inventory races** | Trigger + CHECK | Atomic stock deduction with negative-stock prevention |
| **Index bloat** | Partial indexes | `WHERE order_status = 'pending'` indexes only active records |

---

## 🧬 SQL Concepts Covered

<table>
  <tr>
    <th>Category</th>
    <th>Concepts</th>
  </tr>
  <tr>
    <td><strong>📐 Schema Design</strong></td>
    <td><code>CREATE TABLE</code> · <code>BIGSERIAL</code> · <code>ENUM</code> · <code>CHECK</code> · <code>UNIQUE</code> · <code>FOREIGN KEY</code> · <code>ON DELETE CASCADE</code></td>
  </tr>
  <tr>
    <td><strong>📝 Data Manipulation</strong></td>
    <td><code>INSERT...SELECT</code> · <code>JOIN</code> × 5 · <code>GROUP BY</code> · <code>HAVING</code> · <code>ORDER BY</code> · <code>LIMIT</code></td>
  </tr>
  <tr>
    <td><strong>📊 Analytics</strong></td>
    <td><code>COUNT</code> · <code>AVG</code> · <code>SUM</code> · <code>RANK()</code> · <code>ROW_NUMBER()</code> · <code>FILTER(WHERE)</code> · Window Functions</td>
  </tr>
  <tr>
    <td><strong>⚡ Performance</strong></td>
    <td><code>B-Tree</code> · <code>GIN</code> · <code>IVFFLAT</code> · Partial Index · Composite Index · <code>PARTITION BY RANGE</code></td>
  </tr>
  <tr>
    <td><strong>🔧 Automation</strong></td>
    <td><code>TRIGGER</code> · <code>FUNCTION</code> · <code>MATERIALIZED VIEW</code> · <code>REFRESH CONCURRENTLY</code></td>
  </tr>
  <tr>
    <td><strong>📦 Modern PG</strong></td>
    <td><code>JSONB</code> · <code>jsonb_build_object</code> · <code>@></code> · <code>tsvector</code> · <code>ts_rank</code> · <code>to_tsquery</code></td>
  </tr>
  <tr>
    <td><strong>🧠 AI / Vector</strong></td>
    <td><code>vector(384)</code> · <code><-></code> · <code>AVG(embedding)</code> · <code>IVFFLAT</code> · Hybrid scoring</td>
  </tr>
</table>

---

## 📁 Repository Structure

```
project-2-ecommerce-database/
│
├── 📄 setup_database.sql        → Create DB + enable pgvector
├── 📄 schema.sql                → 30 tables with constraints & AI columns (natively partitioned)
├── 📄 indexes.sql               → B-Tree, GIN, IVFFLAT indexes
├── 📄 triggers.sql              → 6 automated trigger functions
├── 📄 seed.sql                  → 15M+ synthetic records + vector embeddings
├── 📄 materialized_views.sql    → 4 pre-computed dashboard views
├── 📄 analytics.sql             → 20 analytics queries (6 levels)
├── 📄 ai_queries.sql            → 10 pgvector AI queries
├── 📄 README.md                 → This documentation
└── 📁 docs/                     → Assets (banner image)
```

**Execution order:**
```
setup_database → schema → triggers → indexes → seed → materialized_views → analytics → ai_queries
```

---

## 📈 Future Improvements

| Enhancement | Description |
|:---|:---|
| 🐍 **Real Embedding Pipeline** | Python + sentence-transformers to generate actual embeddings |
| 🚀 **FastAPI Layer** | REST API with pgvector-backed search endpoints |
| 📡 **Real-Time Streaming** | Kafka / Debezium CDC for event-driven analytics |
| 🔄 **HNSW Indexes** | Higher recall vector search for production workloads |
| 📋 **Stored Procedures** | Encapsulate multi-step business logic |
| 📊 **Grafana Dashboards** | Connect materialized views to visual dashboards |
| 🛡️ **Row-Level Security** | Multi-tenant seller data isolation |
| 🧪 **pgTAP Testing** | Automated test suites for triggers and constraints |

---

## 📚 This Is Part of a Series

| # | Project | Domain | Complexity | Status |
|:-:|:--------|:-------|:-----------|:------:|
| 1 | 🎓 **Student Management System** | University Academics | ⭐⭐ | ✅ Complete |
| 2 | 🛒 **AI E-Commerce Platform** | Online Retail + AI | ⭐⭐⭐⭐⭐ | ✅ Complete |
| 3 | 🤖 **Agent Memory Database** | AI Memory Systems | ⭐⭐⭐⭐⭐ | 🔜 Coming Soon |

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!
Check the [issues page](https://github.com/aman-bhaskar-codes/sql-data-systems-projects/issues).

## 📄 License

This project is [MIT](https://opensource.org/licenses/MIT) licensed.

---

<p align="center">
  <sub>Built with ❤️ using PostgreSQL + pgvector</sub><br/>
  <sub>Part of the <strong>SQL Data Systems Projects</strong> series</sub>
</p>

<p align="center">
  <a href="https://github.com/aman-bhaskar-codes">
    <img src="https://img.shields.io/badge/GitHub-aman--bhaskar--codes-181717?style=for-the-badge&logo=github&logoColor=white" />
  </a>
</p>
