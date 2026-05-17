# **Project Requirement Document**

## **Project Name: Yarn Petals Data Transformation & Power BI Dashboard Redevelopment**

**Client:** Ivy (Yarn Petals — E-commerce Crochet Flower Brand)  
**Prepared By:** Minh Duc

Tool: Google Colab, Power BI, Excel

Language: Python

---

# **1\. Business Problem Statement**

Yarn Petals has been operating for 3 years using multiple data sources to track sales performance:

* Shopify export dataset  
* Manual order Excel file (staff input)  
* Previously structured dataset used for Excel dashboard

Currently:

* The Shopify dataset is messy and unstructured  
* The manually inputted 2025 order file does not match the structured dataset  
* The structured dataset does not align with Shopify exports  
* Instagram and Facebook orders lack order numbers  
* Three datasets are inconsistent and cannot be reconciled

As the business is transitioning ownership, the owner requires:

* Accurate, unified, and structured data  
* A scalable and automated data mapping process  
* A modern and reliable dashboard  
* A solution that reduces manual cleaning and risk of reporting errors

Without intervention, the business faces:

* Incorrect financial reporting  
* Inaccurate performance analysis  
* Operational inefficiencies  
* Reduced decision-making confidence

---

# **2\. Project Objectives**

1. Create a **universal structured dataset format file**  
2. Develop a **Python automation script** to clean and map Shopify exports  
3. Standardise manual and social media orders  
4. Build an interactive **Power BI dashboard**  
5. Ensure the solution is transferable and scalable for the new owner

---

# **3\. Scope of Work**

## **In Scope**

### **Data Engineering**

* Analyse existing 3 datasets  
* Define universal structured schema  
* Develop Python script to:  
  * Clean Shopify raw export  
  * Map columns into structured format  
  * Standardise field naming  
  * Generate missing Order Numbers for Instagram & Facebook orders  
  * Export final cleaned dataset

### **Data Standardisation**

Final structured dataset columns:

* Date  
* Order Number  
* Name  
* Sale Channels  
* Products  
* Animals  
* Colour  
* Occasions  
* Shipping Method  
* Shipping Fee  
* Product Price  
* Total  
* State  
* Email

### **Dashboard Development (Power BI)**

Rebuild dashboard including:

**Core Metrics**

* Net Sales  
* Sold Bundles  
* Sales by Channel  
* Total Customer

**Filtering Capabilities**

* Product  
* Animal  
* Colour  
* Date  
* Occasion

**Visual Analytics**

* Net Sales by Month  
* Total Bundles per Month  
* % Sold Product by Colour  
* % Sold Product Overall  
* % Sold Animal Flowers  
* % Sold Occasions  
* Orders by Sales Channel

### **UI/UX**

* Apply Yarn Petals branding colours  
* Clean executive-level layout  
* Owner & partner friendly interface

---

## **Out of Scope**

* Shopify system restructuring  
* ERP integration  
* Automation of Instagram/Facebook order capture  
* Real-time API integration  
* Financial accounting reconciliation

---

# **4\. Functional Requirements**

## **4.1 Data Processing**

| ID | Requirement |
| ----- | ----- |
| FR1 | System must accept Shopify CSV export file as input |
| FR2 | Python script must clean and standardise Shopify dataset |
| FR3 | Script must map Shopify columns into universal dataset format |
| FR4 | Script must generate unique Order Number for all orders |
| FR5 | System must validate mandatory fields (Date, Product Price, Total) |
| FR6 | Script must output structured CSV ready for Power BI |
| FR7 | Manual order file must be transformable into same universal structure |

---

## **4.2 Dashboard**

| ID | Requirement |
| ----- | ----- |
| FR8 | Dashboard must calculate Net Sales |
| FR9 | Dashboard must calculate Sold Bundles |
| FR10 | Dashboard must support multi-filter (Product, Animal, Colour, Date, Occasion) |
| FR11 | Dashboard must show Monthly Sales Trend |
| FR12 | Dashboard must show % distribution of Colour |
| FR13 | Dashboard must show % distribution of Animal Flowers |
| FR14 | Dashboard must show % distribution of Occasion |
| FR15 | Dashboard must show Orders by Sale Channel |
| FR16 | Dashboard must reflect branding colours |

---

# **5\. Non-Functional Requirements**

| Category | Requirement |
| ----- | ----- |
| Performance | Python script must process file within 30 seconds for up to 10,000 rows |
| Usability | Staff must be able to run Python file without coding knowledge |
| Reliability | Data mapping must produce consistent output format |
| Maintainability | Code must be documented and editable |
| Scalability | Dataset must allow additional columns in future |
| Security | Customer email data must not be publicly exposed |
| Compatibility | Power BI dashboard must work on desktop and cloud |

---

# **6\. Proposed Solution Architecture**

**Step 1: Data Input**

* Shopify CSV  
* Manual Excel file  
* Social Media Order file

⬇

**Step 2: Python ETL Script**

* Clean  
* Map  
* Standardise  
* Generate missing order numbers

⬇

**Step 3: Universal Structured Dataset**  
Single source of truth dataset

⬇

**Step 4: Power BI Dashboard**  
Executive visual reporting layer

---

# **7\. Business Rules:**

**Sales Channel**: Dating Apps, Direct, Facebook, Franchise, Instagram, Website

**Product**: Beach Walk Bundle, Bloom Bundle, Blush of Love Bundle, Bud Bundle, Bud Bundle (Style 1), Bud Bundle (Style 2), Christmas Bundle, Customized Bundle, Flowers Add On, Lavender Dream Bundle, Leaf Bundle, Love Garden Bundle, Matcha Date Bundle, NG, Single Bundle, Sprout Bundle, Sunshine Bundle, Beechiever Bundle, Chubberry Bundle, Sunrose Bundle, Hanakatsu Bundle, Tonkatsu Bundle, Chicken Katsu Bundle, Ebi Katsu Bundle, Largest Bundle.

If the product name is: Special Customized Bundle (Largest Size) or with the Product Price $100 then rename to Largest Bundle 

If the product name is Bud Bundle (Style 1\) and Bud Bundle (Style 2\) rename to Bud Bundle

If the cell name is blank, fill the cell with NG

**Animal**: Alpaca, Bacon, Brown Cat, Bunny, Cat, Customized, Ducky, Froggie, Grey Cat, Koala, Leave, Moo, NG, Penguin, Pink, Puppy, Queen Bee, Sheep, Ted, Ebi Katsu, Hana Katsu, Tonkatsu, Chickenkatsu

If the cell is blank, fill the cell with NG

If the product name is Hanakatsu Bundle then the Animal is Hana Katsu

If the product name is Tonkatsu Bundle then the Animal is Tonkatsu

If the product name is Chicken Katsu Bundle then the Animal is Chickenkatsu

If the product name is Ebi Katsu Bundle. then the Animal is Ebi Katsu

**Colour:** Blue, Green, NG, Orange, Pink, Pink/ Purple, Pink/ Yellow, Purple, Yellow

If the cell is blank, fill the cell with NG

**Occasions**: Birthday, Couples, Family, Friends, Graduation, Mother's Day, None, Valentine, Farewell, Give away, Anniversary

If the Accessories is Graduation hat, then occasion is Graduation

If the Accessories is Birthday hat, then occasion is Birthday

Else is None

If if product name is Lavender Dream Bundle, Blush of Love Bundle, Sunshine Bundle, Matcha Date Bundle, Beach Walk Bundle and the Accessories is None or NG then the Occasion is Couple

# 

# **8\. Timeline**

| Phase | Task | Date |
| ----- | ----- | ----- |
| Phase 1 | Requirement Finalisation | 20–22 Feb |
| Phase 2 | Data Analysis & Schema Design | 23–25 Feb |
| Phase 3 | Python ETL Development | 26 Feb – 5 March |
| Phase 4 | Testing & Data Validation | 6–8 March |
| Phase 5 | Power BI Dashboard Development | 9–13 March |
| Phase 6 | Final Review & Deployment | 14–15 March |

---

# **9\. Expected Results**

After implementation:

✅ Single structured dataset (source of truth)  
✅ Automated Shopify file cleaning process  
✅ Elimination of data mismatch issues  
✅ Reduced manual data cleaning time  
✅ Improved reporting accuracy  
✅ Professional Power BI dashboard  
✅ Owner transition-ready analytics system  
✅ Data-driven decision making capability

---

# **10\. Business Value**

* Increased operational efficiency  
* Reduced human error  
* Stronger investor confidence  
* Improved strategic planning  
* Long-term scalability

