// W3wp interacting with suspicious DLL files 
// https://www.cisa.gov/news-events/cybersecurity-advisories/aa23-074a
DeviceFileEvents
| where FileName matches regex @"^.*\\\d{10}\.\d{7}\.dll$" or FileName matches regex @"^.*\\\d{10}\.\d{7}\.dll$"
| where InitiatingProcessFileName == "W3wp.exe"