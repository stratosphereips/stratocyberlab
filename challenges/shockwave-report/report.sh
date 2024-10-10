#!/bin/bash

# oh no, you found me :(
# BSY{cIAXNcTzjPEkH5nZU1LV6uPrSIvHpGPEoApUQXfkyftsZOmnsUokQeUfDmEW}

echo "Content-type: text/html"
echo

# Simulate system diagnostics output
echo "<html><body>"
echo "<h1>System Information Report</h1>"

# Print the server's uptime
echo "<p><strong>Server Uptime:</strong> $(uptime)</p>"

# Show the current disk usage
echo "<p><strong>Disk Usage:</strong></p>"
echo "<pre>$(df -h)</pre>"

# Show memory usage
echo "<p><strong>Memory Usage:</strong></p>"
echo "<pre>$(free -m)</pre>"

# Display current users
echo "<p><strong>Currently Logged In Users:</strong></p>"
echo "<pre>$(who)</pre>"

# Show active processes (top 5 CPU consumers)
echo "<p><strong>Top 5 Processes by CPU Usage:</strong></p>"
echo "<pre>$(ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -6)</pre>"

# Show network configuration
echo "<p><strong>Network Configuration:</strong></p>"
echo "<pre>$(ifconfig)</pre>"

# A hidden vulnerability: output Bash version, masked in a comment to avoid immediate detection
# This is where the vulnerability lies (Bash is processing environment variables)
echo "<!-- Debug Info: Bash Version: $(/bin/bash --version | head -n 1) -->"

# Simulate more complex behavior with conditional logic
if [ -z "$DEBUG" ]; then
    echo "<p><strong>Diagnostic Mode Disabled:</strong> Enable diagnostics by setting DEBUG=true in the environment.</p>"
else
    echo "<p><strong>Diagnostic Mode Enabled:</strong> Printing additional debug information.</p>"
    echo "<pre>$(dmesg | tail -n 10)</pre>"
fi

# End of the HTML output
echo "</body></html>"
