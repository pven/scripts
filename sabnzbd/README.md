\# SABnzbd Scripts



This folder contains scripts related to SABnzbd.



\## 📌 Scripts



\### prequeue\_size\_pause\_big.py

Automatically pauses large downloads when the pre-queue grows too big.  

Useful to keep SABnzbd under control.



\#### ▶️ Setup

1\. In SABnzbd, go to \*\*Settings → Categories\*\* and create a category called `big`.  

2\. Copy the script to the SABnzbd scripts folder (e.g. `/config/scripts`) and make sure it is executable.  

3\. In SABnzbd, go to \*\*Settings → Switches → Pre-queue script\*\* and select this script.  

4\. Configuration: in the script you can adjust the line starting with `THRESH\_GB` to change the threshold (default: `80 GB`).  



