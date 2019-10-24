# Insight-2019
* Session 1403-2: Advanced PowerShell Techniques
* Session 1402-1: Administer Your NetApp Storage Environment Using PowerShell Essentials

# Related Sessions
* Session 2018-2: Harnessing the Power of ONTAP Infrastructure Testing with Pester

## Who this is for:
* You have some experience with PowerShell and are looking to write more mature scripts, functions, classes, and modules
* Part of your work responsibilities include managing NetApp storage devices.
* You won’t be an expert in PowerShell or ONTAP storage administration using PowerShell after reading this. However, you should leave with some basic fundamental building blocks necessary for developing more advanced scripts.

## Some topics we wanted to talk more about (but couldn’t due to time)
* Error handling
* PowerShell Adapted Type Systems (ATS) and Extended Type Systems (ETS)

## Previous PowerShell talks
* Storage Infrastructure Testing Using PowerShell and Pester ( Insight 2018 - Session 11942 )
* Advanced PowerShell Storage Provisioning Lifecycle ( Insight 2018 - Session 11923 )

## Using the examples
* This repo is based around the concept of demos. The expectation is the you have a NetApp Cluster created with:
    * SVM Named: TestSVM
    * ISCSI target Lifs: iscsi1 and iscsi2
* Open PowerShell and navigate to the git repo
* Load Start-Demo into memory
* Call one of the demos!

```powershell
PS > . ./Examples/Start-Demo.ps1
PS > Start-Demo ./Examples/1403-2_Advanced/0.ScriptToModule.demo
```

## TODO
- [X] Converting a script to a module
    - [X] Script to Function
    - [X] Module Manifest 
- [ ] Script - compare LUNs to VMware canonical names using subfunctions
    - [ ] Unit Test it
- [X] Classes - What they are and where to use them
    - [X] Show subfunctions vs classes
    - [ ] Unit Test It
- [X] Quick Overview of DSC and its uses 
    - [ ] Comparison to an ansible playbook
    - [X] Gherkin Testing
    - [X] Diagnostic Testing
- [X] Invoke-RestMethod for ONTAP 9.6 and beyond
- [X] Automation vs Interactive Scripts (In PowerPoint)
