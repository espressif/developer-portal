---
title: "RED-DA Compliant Matter devices with ESP-ZeroCode"
date: "2025-12-08"
# If default Espressif author is needed, uncomment this
# showAuthor: true
# Add a summary
summary: "In this blog we will introduce how combining the Espressif RED-DA compliance framework along with the ESP ZeroCode platform can help accelerate your product development"
# Create your author entry (for details, see https://developer.espressif.com/pages/contribution-guide/writing-content/#add-youself-as-an-author)
#  - Create your page at `content/authors/<author-name>/_index.md`
#  - Add your personal data at `data/authors/<author-name>.json`
#  - Add author name(s) below
authors:
  - "anant-raj-gupta" # same as in the file paths above
# Add tags
tags: ["REDDA", "Matter", "ZeroCode"]
---

With the EU **Radio Equipment Directive Delegated Act (RED‑DA)** now in effect, all radio equipment placed on the EU market must meet the mandatory cybersecurity and update requirements defined in **EN 18031**.

Espressif has integrated RED‑DA support into the **ESP‑ZeroCode** platform, enabling developers and product teams to generate **Matter firmware and a RED‑DA‑oriented documentation package in one step**. This integration reduces manual work, simplifies technical documentation, and accelerates time‑to‑market for EU‑bound Matter devices.

{{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5">}}
 As with all RED‑DA workflows, the **end‑product manufacturer** remains responsible for the final Declaration of Conformity and for ensuring that the complete device (hardware + firmware + cloud/backend) meets the applicable EN 18031 requirements.
{{< /alert >}}


## What’s new: Integrated RED‑DA support in ESP‑ZeroCode

ESP‑ZeroCode now delivers a **RED‑DA documentation starter package** alongside the generated device firmware:

- **Pre‑filled compliance templates**  
  Espressif provides documentation aligned with EN 18031 and our RED‑DA guidance, including:
  - Platform‑level security features and defaults  
  - Network stack and secure update mechanisms  
  - Standard technical specifications for the ESP‑ZeroCode Matter platform  

- **Documentation structured for final use**  
  The package is organized to match typical RED‑DA technical documentation expectations, so it can be:
  - Used directly for **self‑assessment and Declaration of Conformity**, or  
  - Used as input for **Approved Testing Laboratories (ATLs) or Notified Bodies**, when needed  

With this integration, developers no longer have to assemble the technical file from scratch. **Platform‑level conformance** is captured by Espressif’s pre‑filled content, while the manufacturer completes the remaining device‑specific sections as part of their normal product documentation flow.

## How the integration works

### Pre‑filled compliance templates

The templates provided via ESP‑ZeroCode are derived from Espressif’s RED‑DA documentation framework described in **RED‑DA Compliance Part 2** and prepared in collaboration with **Brightsight**:

- Based on **EN 18031** mappings for Article 3(3)(d)/(e)/(f), where applicable  
- Include:
  - Platform security configuration and defaults  
  - Secure communication and cryptography settings  
  - OTA / secure update capabilities  

These templates serve as a **starting point** for the final technical documentation package expected by Market Surveillance Authorities and Notified Bodies.

### Product‑specific inputs by the manufacturer

The end‑product manufacturer augments the templates with device‑specific information to complete the technical file. Typical additions include:

- Detailed device description and intended use  
- Target user group and installation environment  
- Mechanical design and PCB schematics  
- Power, radio, and enclosure details  
- Application‑level behavior and any customizations that may affect security or privacy  

This ensures that the documentation accurately reflects the **actual device, operational environment, and manufacturing setup**, while still leveraging Espressif’s platform‑level content.

### Documentation delivered with firmware

ESP‑ZeroCode exports both the **production‑ready Matter firmware** and the **RED‑DA documentation starter package** in one step:

- The package includes Espressif’s pre‑filled sections for the ESP‑ZeroCode platform and the device type configured based on the connectivity as well as the SoC chosen
- Placeholders and headings make it clear where manufacturers should add their own product details  
- Once completed, the package can be used for:
  - RED‑DA **self‑declaration** (Declaration of Conformity issued by the manufacturer), or  
  - Submissions to an **ATL or Notified Body**, when a formal third‑party assessment is preferred or required  

## Workflow: From device design to RED‑DA‑oriented package

1. Select or customize a device template in ESP‑ZeroCode.  
2. Configure Matter device using the standard ESP‑ZeroCode workflow.  
3. Check the **EU RED-DA** checkbox in the ESP-ZeroCode Benfits page.  
{{< figure
    default=true
    src="./img/esp-zerocode-benefits.webp"
    caption="ESP-ZeroCode Benefits"
>}}
1. Complete product‑specific sections in the provided templates as part of your internal documentation process.  
{{< figure
    default=true
    src="./img/esp-zerocode-red-da-details.webp"
    caption="ESP-ZeroCode RED-DA Product Details"
>}}

1. Use the completed package for RED‑DA self‑assessment or as input to an ATL/Notified Body, and proceed to Matter ecosystem certification if applicable.

This integrated workflow reduces manual documentation work and provides a clear, unified path toward EU compliance.

## Benefits for developers and product teams

Espressif’s integrated solution provides concrete advantages for **any developer building Matter devices for the EU market**:

- **Single‑step delivery** of firmware + RED‑DA documentation starter package  
- **Reduced manual effort** in preparing technical files  
- **Clear responsibility split**  
  - Espressif: platform‑level documentation and security configuration  
  - Manufacturer: product‑specific details and final conformity decision  
- **Faster EU market entry** with pre‑validated platform documentation  
- **Confidence in security and interoperability**: templates incorporate Espressif’s EN 18031‑aligned safeguards at the platform level  
- **Simplified scaling across multiple device variants** without repeating core platform compliance work  
- **Accessible for teams of any size**, from solo developers to larger organizations  

This approach allows teams to focus on **innovation and differentiation**, while Espressif provides a strong regulatory foundation at the platform level.

## Example use case

A team building a Matter‑enabled smart light for the EU market can:

1. Use **ESP‑ZeroCode** to configure the smart light profile and select an appropriate Matter device template.  
2. Generate the **firmware + RED‑DA documentation starter package**.  
3. Add product‑specific information such as **manufacturer details, PCB schematics, operational environment, and model identifiers** into the templates.  
4. Use this package for **RED‑DA self‑declaration** or as input to an ATL / Notified Body, depending on their chosen compliance pathway.  

The result: faster launch, reduced engineering effort, and RED‑DA‑oriented Matter devices with minimal manual documentation work.

## Conclusion

By integrating RED‑DA support into **ESP‑ZeroCode**, Espressif provides a streamlined, end‑to‑end path for Matter device development targeting the EU market. Developers and product teams can now generate **firmware and RED‑DA‑aligned documentation together**.

This unified approach reduces engineering effort, minimizes compliance risk, and accelerates time‑to‑market for secure, interoperable, and EU‑ready Matter devices.

---

## Further reading

- Explore **ESP‑ZeroCode**:  
  <https://zerocode.espressif.com>  

- Read Espressif’s **RED‑DA guides**:  
  - Part 1 – *RED‑DA (EN 18031) Certification Compliance: What You Need to Know*  
    <https://developer.espressif.com/blog/2025/04/esp32-red-da-en18031-compliance-guide/>  
  - Part 2 – *RED‑DA Compliance (Part 2): Espressif’s Platform Support, Templates, and Pathways for Conformity*  
    <https://developer.espressif.com/blog/2025/07/esp32-red-da-en18031-compliance-guide-part2/>  

