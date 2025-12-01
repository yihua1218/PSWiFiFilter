using System;

namespace WiFiFilterGUI
{
    public class NetworkItem
    {
        public string SSID { get; set; }
        public string Signal { get; set; }
        public string Security { get; set; }
        public bool IsAllowed { get; set; }

        public override string ToString()
        {
            return SSID;
        }
    }
}
