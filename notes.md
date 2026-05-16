# ALUR ANALISIS AIRBNB EUROPE MARKET
(Framework Lengkap + Alur Berpikir)

## 📊 Dataset Overview
* **listings**: Data *Supply* (properti, lokasi, tipe, host, dll).
* **past_rates**: Data *Historical Performance* (occupancy, revenue, ADR, RevPAR).

## 🎯 Tujuan Utama
1.  **Cross-market comparison**: Performa antar kota dan negara di Eropa.
2.  **Investment screening**: Identifikasi market STR terbaik (Occupancy, ADR, RevPAR).
3.  **Seasonality analysis**: Pola musiman di berbagai market.
4.  **Supply analysis**: Densitas listing, tipe properti, dan tingkat manajemen profesional.
5.  **Academic research**: Dampak regulasi, ekonomi pariwisata, dan pasar perumahan.

---

## 🧠 MINDSET UTAMA
Jangan langsung berpikir: **"Market mana terbaik?"**
Tetapi berpikir: **"Bagaimana struktur supply, demand, pricing, dan profitability market Airbnb di Eropa?"**

Airbnb adalah kombinasi dari:
* Tourism economics
* Real estate
* Hospitality
* Platform economy

---

## 🚀 STRUKTUR BERPIKIR ANALISIS
Gunakan alur:
**SUPPLY → DEMAND → PERFORMANCE → COMPETITION → INVESTMENT → ECONOMIC IMPACT**

---

## PHASE 1 — DATA UNDERSTANDING
**Tujuan:** Memahami isi dataset, relasi tabel, dan granularity data.
* **listings**: 1 row = 1 listing/property (**SUPPLY SIDE**).
* **past_rates**: 1 row = performa listing pada waktu tertentu (**DEMAND + PERFORMANCE SIDE**).

---

## PHASE 2 — DATA CLEANING & VALIDATION
**Tujuan:** Memastikan data valid dan tepercaya.
* **Missing Values**: Cek `listing_id` NULL.
* **Duplicate Listing**: Cek ID ganda.
* **Invalid Occupancy**: Pastikan nilai antara 0 dan 1.
* **Negative Revenue**: Hapus data pendapatan tidak wajar.

---

## PHASE 3 — MARKET STRUCTURE ANALYSIS
**Tujuan:** Memahami struktur pasar Airbnb Eropa.
1.  **Listing Density**: Kota/Negara mana yang paling jenuh (saturated)?
2.  **Property Type Structure**: Dominasi tipe properti (Apartment vs Villa).
3.  **Entire Home Dominance**: Indikator komersialisasi pasar.

---

## PHASE 4 — PROPERTY SEGMENTATION
**Tujuan:** Membagi market karena properti Airbnb tidak homogen.
* **Property Type vs Occupancy**: Demand tertinggi.
* **Property Type vs ADR**: Pricing power.
* **Property Type vs RevPAR**: Efisiensi profitabilitas (Paling Penting).

---

## PHASE 5 — PERFORMANCE ANALYSIS
**Tujuan:** Menentukan market terbaik berdasarkan KPI.
* **Occupancy**: Kekuatan demand.
* **ADR**: Kekuatan harga.
* **RevPAR**: Efisiensi pendapatan.
* **Kategori**:
    * *High occupancy + High ADR*: Elite market.
    * *High occupancy + Low ADR*: Mass tourism.
    * *Low occupancy + High ADR*: Luxury niche.

---

## PHASE 6 — INVESTMENT SCREENING
**Tujuan:** Mencari market terbaik untuk investasi.
* **RevPAR**: Metrik utama.
* **Occupancy Stability**: Menggunakan Volatilitas (Standard Deviation).
* **Competition Level**: Densitas listing.

---

## PHASE 7 — SEASONALITY ANALYSIS
**Tujuan:** Memahami fluktuasi pariwisata.
1.  **Monthly Occupancy**: Menentukan Peak & Low Season.
2.  **Seasonality Strength**: Mengukur risiko investasi berdasarkan volatilitas bulanan.

---

## PHASE 8 — SUPPLY & COMPETITION ANALYSIS
**Tujuan:** Memahami tingkat profesionalisme.
* **Professional Management Rate**: Persentase listing yang dikelola host profesional (lebih dari 1 listing).

---

## PHASE 9 — ACADEMIC / ECONOMIC RESEARCH
**Tujuan:** Insight dampak sosial-ekonomi.
* **Tourism Economics**: Hubungan demand dan pricing.
* **Housing Commercialization**: Dampak pada pasar hunian lokal.
* **Regulation Impact**: Pengaruh aturan terhadap supply dan occupancy.

---

## PHASE 10 — ADVANCED ANALYSIS
1.  **Clustering Market**: Kelompok market berdasarkan karakteristik.
2.  **Forecasting**: Prediksi revenue masa depan.
3.  **Regression**: Faktor penentu revenue (Reviews, Superhost, dll).

---

## 🔝 FLOW ANALISIS IDEAL
1. Data Cleaning
2. Market Structure
3. Property Segmentation
4. Performance Metrics
5. Seasonality
6. Supply & Competition
7. Investment Screening
8. Economic/Regulation Interpretation