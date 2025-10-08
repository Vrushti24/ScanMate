# 📱 ScanMate
**A Complete Document Scanning and Management Solution for iOS**  
Built with **SwiftUI + UIKit Integration** | Powered by **Core Data** | Privacy-First Architecture  

---

## 🚀 Overview
**ScanMate** is a next-generation iOS application that redefines document scanning with speed, intelligence, and privacy.  
Built using **SwiftUI** and **UIKit**, it provides users with high-quality document scanning, smart cropping, OCR text extraction, annotation tools, and organized file management — all within a clean, intuitive interface.

Unlike cloud-dependent apps, **ScanMate** ensures full data control by storing all files locally through **Core Data** and the iOS file system.  
The app combines a modern SwiftUI design with robust engineering to deliver a professional, secure, and seamless scanning experience.

---

## ✨ Key Features
- 📸 **High-Quality Document Scanning** — native camera integration with smooth capture flow.  
- ✂️ **Smart Cropping & Filters** — automatic edge detection and image enhancement.  
- 🖊️ **Drawing, Annotations & Signatures** — add handwritten notes or digital marks.  
- 🔍 **OCR Text Extraction** — convert scanned content into editable, shareable text.  
- 🗂️ **Folder & Tag Management** — organize documents efficiently.  
- 📤 **Export as PDF** — save or share professional-grade documents.  
- 🔒 **Offline Privacy** — all data stored locally; no third-party cloud servers.  

---

## 🧱 Architecture Overview
Camera Input
↓
ScanView → EditView → Core Data Storage → File System (PDFs)
↓
OCR Extraction → Organized via Folders & Tags → Export / Share


**Core Components**
| Component | Purpose |
|------------|----------|
| `ScanView` | Handles document scanning and importing |
| `EditView` | Supports cropping, filtering, drawing, and annotation |
| `MainTabView` | Navigation between Files and Folders |
| `PDFViewerScreen` | Renders PDFs for preview and sharing |
| `Core Data` | Manages metadata and relationships |
| `File System` | Stores PDF files securely on-device |

---

## 🛠️ Tech Stack
- **Language:** Swift 5.x  
- **Frameworks:** SwiftUI, UIKit, VisionKit, Core Data, PDFKit  
- **Architecture:** MVVM + Modular Components  
- **Platforms:** iOS 16.0 and later  
- **IDE:** Xcode 15+  

---

## 📸 Screenshots

<div align="center">

<img src="https://github.com/user-attachments/assets/16654980-2666-4815-89be-7a2c481b161d" width="200" />
<img src="https://github.com/user-attachments/assets/396009d9-19c3-4b49-9dc1-f434a0749a03" width="200" />
<img src="https://github.com/user-attachments/assets/c13b5e1f-1b56-46e0-953c-3727f1e2a8ed" width="200" />
<br/>

<img src="https://github.com/user-attachments/assets/d56f650b-b672-4b7f-8ac8-d30de61ca532" width="200" />
<img src="https://github.com/user-attachments/assets/4416f7b2-d1e6-4c9c-8796-ddceb7a58f52" width="200" />
<img src="https://github.com/user-attachments/assets/03814697-887a-4e44-aece-c9fc9979bb54" width="200" />
<br/>

<img src="https://github.com/user-attachments/assets/70f4f037-786e-4b3d-87f8-5192d3fe395e" width="200" />
<img src="https://github.com/user-attachments/assets/6ade6cf5-acf2-454a-a073-a55c34302d3f" width="200" />
<img src="https://github.com/user-attachments/assets/75b20c01-883d-4921-ad77-520ab96665ae" width="200" />
<br/>

<img src="https://github.com/user-attachments/assets/4a4e69a6-27c6-483a-a825-1704ccae7f00" width="200" />
<img src="https://github.com/user-attachments/assets/d5f42b61-98a9-4710-9b38-93c8c876a805" width="200" />
<img src="https://github.com/user-attachments/assets/c6bad82c-9b64-4c02-b7b7-1b12da058fb8" width="200" />
<br/>

<img src="https://github.com/user-attachments/assets/a987e1f1-bacd-49c0-b17a-fde024d7d4af" width="200" />
<img src="https://github.com/user-attachments/assets/f803e7a9-b134-4918-bd9a-66f683df8d7a" width="200" />
<img src="https://github.com/user-attachments/assets/aa01a2b5-6625-4870-b826-3f05a0f0e0d2" width="200" />
<br/>

<img src="https://github.com/user-attachments/assets/07d514a3-88af-40fa-9ba0-4c474b18b87f" width="200" />

</div>

