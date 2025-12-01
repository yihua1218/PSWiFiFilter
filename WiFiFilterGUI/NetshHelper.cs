using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace WiFiFilterGUI
{
    public static class NetshHelper
    {
        public static async Task<List<NetworkItem>> GetNetworksAsync()
        {
            string output = await RunNetshCommandAsync("wlan show networks mode=bssid");
            return ParseNetworks(output);
        }

        public static async Task<bool> AddFilterAsync(string ssid)
        {
            string output = await RunNetshCommandAsync($"wlan add filter permission=allow ssid=\"{ssid}\" networktype=infrastructure");
            return !output.Contains("Error");
        }

        public static async Task<bool> RemoveFilterAsync(string ssid)
        {
            // Try removing both allow and block filters to be safe, similar to the script
            await RunNetshCommandAsync($"wlan delete filter permission=allow ssid=\"{ssid}\" networktype=infrastructure");
            string output = await RunNetshCommandAsync($"wlan delete filter permission=block ssid=\"{ssid}\" networktype=infrastructure");
            return !output.Contains("Error");
        }

        public static async Task<bool> BlockAllAsync()
        {
            string output = await RunNetshCommandAsync("wlan add filter permission=denyall networktype=infrastructure");
            return !output.Contains("Error");
        }

        public static async Task<bool> ClearFiltersAsync()
        {
            await RunNetshCommandAsync("wlan delete filter permission=denyall networktype=infrastructure");
            await RunNetshCommandAsync("wlan delete filter permission=denyall networktype=adhoc");
            
            // We can't easily list all individual filters to delete them one by one without parsing 'netsh wlan show filters'
            // For now, let's assume the user wants to reset to a clean state where they can see everything.
            // The original script parses 'netsh wlan show filters' to remove individual SSIDs.
            // Let's implement that.
            
            string filtersOutput = await RunNetshCommandAsync("wlan show filters");
            var lines = filtersOutput.Split(new[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries);
            foreach (var line in lines)
            {
                var match = Regex.Match(line, @"SSID\s+:\s+(.+)");
                if (match.Success)
                {
                    string ssid = match.Groups[1].Value.Trim();
                    await RemoveFilterAsync(ssid);
                }
            }

            return true;
        }

        private static async Task<string> RunNetshCommandAsync(string arguments)
        {
            return await Task.Run(() =>
            {
                try
                {
                    Process process = new Process();
                    process.StartInfo.FileName = "netsh";
                    process.StartInfo.Arguments = arguments;
                    process.StartInfo.RedirectStandardOutput = true;
                    process.StartInfo.UseShellExecute = false;
                    process.StartInfo.CreateNoWindow = true;
                    process.StartInfo.StandardOutputEncoding = System.Text.Encoding.UTF8; // Ensure correct encoding
                    process.Start();
                    string output = process.StandardOutput.ReadToEnd();
                    process.WaitForExit();
                    return output;
                }
                catch (Exception ex)
                {
                    return $"Error: {ex.Message}";
                }
            });
        }

        private static List<NetworkItem> ParseNetworks(string output)
        {
            var networks = new List<NetworkItem>();
            var lines = output.Split(new[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries);

            string currentSsid = null;
            string currentSignal = null;
            string currentAuth = null;

            foreach (var line in lines)
            {
                var ssidMatch = Regex.Match(line, @"^SSID\s+\d+\s+:\s+(.+)$");
                if (ssidMatch.Success)
                {
                    if (currentSsid != null)
                    {
                        networks.Add(new NetworkItem
                        {
                            SSID = currentSsid,
                            Signal = currentSignal ?? "N/A",
                            Security = currentAuth ?? "Unknown"
                        });
                    }
                    currentSsid = ssidMatch.Groups[1].Value.Trim();
                    currentSignal = null;
                    currentAuth = null;
                    continue;
                }

                if (currentSsid != null)
                {
                    var signalMatch = Regex.Match(line, @"^\s+Signal\s+:\s+(.+)$");
                    if (signalMatch.Success)
                    {
                        currentSignal = signalMatch.Groups[1].Value.Trim();
                    }

                    var authMatch = Regex.Match(line, @"^\s+Authentication\s+:\s+(.+)$");
                    if (authMatch.Success)
                    {
                        currentAuth = authMatch.Groups[1].Value.Trim();
                    }
                }
            }

            // Add the last one
            if (currentSsid != null)
            {
                networks.Add(new NetworkItem
                {
                    SSID = currentSsid,
                    Signal = currentSignal ?? "N/A",
                    Security = currentAuth ?? "Unknown"
                });
            }

            return networks.GroupBy(n => n.SSID).Select(g => g.First()).ToList(); // Dedup by SSID
        }
    }
}
