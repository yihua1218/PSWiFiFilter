using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Input;

namespace WiFiFilterGUI
{
    public class MainViewModel : INotifyPropertyChanged
    {
        private ObservableCollection<NetworkItem> _availableNetworks;
        private ObservableCollection<NetworkItem> _allowedNetworks;
        private NetworkItem _selectedAvailableNetwork;
        private NetworkItem _selectedAllowedNetwork;
        private bool _isBusy;
        private string _statusMessage;
        private const string AllowedFile = "allowed_ssids.txt";

        public MainViewModel()
        {
            AvailableNetworks = new ObservableCollection<NetworkItem>();
            AllowedNetworks = new ObservableCollection<NetworkItem>();
            ScanCommand = new RelayCommand(async _ => await ScanNetworksAsync());
            AllowCommand = new RelayCommand(async _ => await AllowNetworkAsync(), _ => SelectedAvailableNetwork != null);
            RemoveCommand = new RelayCommand(async _ => await RemoveAllowedNetworkAsync(), _ => SelectedAllowedNetwork != null);
            ApplyFiltersCommand = new RelayCommand(async _ => await ApplyFiltersAsync(), _ => AllowedNetworks.Count > 0);
            ClearFiltersCommand = new RelayCommand(async _ => await ClearFiltersAsync());

            // Load saved SSIDs
            LoadAllowedNetworks();

            // Initial scan
            _ = ScanNetworksAsync();
        }

        public ObservableCollection<NetworkItem> AvailableNetworks
        {
            get => _availableNetworks;
            set { _availableNetworks = value; OnPropertyChanged(); }
        }

        public ObservableCollection<NetworkItem> AllowedNetworks
        {
            get => _allowedNetworks;
            set { _allowedNetworks = value; OnPropertyChanged(); }
        }

        public NetworkItem SelectedAvailableNetwork
        {
            get => _selectedAvailableNetwork;
            set 
            { 
                _selectedAvailableNetwork = value; 
                OnPropertyChanged(); 
                (AllowCommand as RelayCommand)?.RaiseCanExecuteChanged();
            }
        }

        public NetworkItem SelectedAllowedNetwork
        {
            get => _selectedAllowedNetwork;
            set 
            { 
                _selectedAllowedNetwork = value; 
                OnPropertyChanged();
                (RemoveCommand as RelayCommand)?.RaiseCanExecuteChanged();
            }
        }

        public bool IsBusy
        {
            get => _isBusy;
            set { _isBusy = value; OnPropertyChanged(); }
        }

        public string StatusMessage
        {
            get => _statusMessage;
            set { _statusMessage = value; OnPropertyChanged(); }
        }

        public ICommand ScanCommand { get; }
        public ICommand AllowCommand { get; }
        public ICommand RemoveCommand { get; }
        public ICommand ApplyFiltersCommand { get; }
        public ICommand ClearFiltersCommand { get; }

        private async Task ScanNetworksAsync()
        {
            IsBusy = true;
            StatusMessage = "Scanning networks...";
            AvailableNetworks.Clear();
            var networks = await NetshHelper.GetNetworksAsync();
            foreach (var network in networks)
            {
                // Filter out already allowed networks from available list if desired, 
                // or just show them all. Let's show all but maybe mark them?
                // For simplicity, just list them.
                if (!AllowedNetworks.Any(n => n.SSID == network.SSID))
                {
                    AvailableNetworks.Add(network);
                }
            }
            StatusMessage = $"Found {AvailableNetworks.Count} networks.";
            IsBusy = false;
        }

        private async Task AllowNetworkAsync()
        {
            if (SelectedAvailableNetwork == null) return;

            var network = SelectedAvailableNetwork;
            if (!AllowedNetworks.Any(n => n.SSID == network.SSID))
            {
                AllowedNetworks.Add(network);
                AvailableNetworks.Remove(network);
                SaveAllowedNetworks();
            }
            (ApplyFiltersCommand as RelayCommand)?.RaiseCanExecuteChanged();
        }

        private async Task RemoveAllowedNetworkAsync()
        {
            if (SelectedAllowedNetwork == null) return;

            var network = SelectedAllowedNetwork;
            AllowedNetworks.Remove(network);
            AvailableNetworks.Add(network);
            SaveAllowedNetworks();
            (ApplyFiltersCommand as RelayCommand)?.RaiseCanExecuteChanged();
        }

        private async Task ApplyFiltersAsync()
        {
            IsBusy = true;
            StatusMessage = "Applying filters...";

            // 1. Hide all
            bool hidden = await NetshHelper.BlockAllAsync();
            if (!hidden)
            {
                StatusMessage = "Failed to hide networks.";
                IsBusy = false;
                return;
            }

            // 2. Allow specific SSIDs
            foreach (var network in AllowedNetworks)
            {
                await NetshHelper.AddFilterAsync(network.SSID);
            }

            StatusMessage = "Filters applied successfully.";
            IsBusy = false;
        }

        private async Task ClearFiltersAsync()
        {
            IsBusy = true;
            StatusMessage = "Clearing filters...";
            await NetshHelper.ClearFiltersAsync();
            StatusMessage = "All filters cleared. Showing all networks.";
            AllowedNetworks.Clear();
            await ScanNetworksAsync();
            IsBusy = false;
        }

        private void LoadAllowedNetworks()
        {
            try
            {
                if (System.IO.File.Exists(AllowedFile))
                {
                    var lines = System.IO.File.ReadAllLines(AllowedFile);
                    foreach (var line in lines)
                    {
                        var ssid = line.Trim();
                        if (!string.IsNullOrWhiteSpace(ssid) && !AllowedNetworks.Any(n => n.SSID == ssid))
                        {
                            AllowedNetworks.Add(new NetworkItem { SSID = ssid, Signal = "Saved", Security = "Unknown" });
                        }
                    }
                }
            }
            catch (System.Exception ex)
            {
                StatusMessage = $"Error loading allowed SSIDs: {ex.Message}";
            }
        }

        private void SaveAllowedNetworks()
        {
            try
            {
                var lines = AllowedNetworks.Select(n => n.SSID).ToList();
                System.IO.File.WriteAllLines(AllowedFile, lines);
            }
            catch (System.Exception ex)
            {
                StatusMessage = $"Error saving allowed SSIDs: {ex.Message}";
            }
        }

        public event PropertyChangedEventHandler PropertyChanged;
        protected void OnPropertyChanged([CallerMemberName] string name = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(name));
        }
    }

    public class RelayCommand : ICommand
    {
        private readonly System.Action<object> _execute;
        private readonly System.Predicate<object> _canExecute;

        public RelayCommand(System.Action<object> execute, System.Predicate<object> canExecute = null)
        {
            _execute = execute;
            _canExecute = canExecute;
        }

        public bool CanExecute(object parameter) => _canExecute == null || _canExecute(parameter);
        public void Execute(object parameter) => _execute(parameter);
        public event System.EventHandler CanExecuteChanged;
        public void RaiseCanExecuteChanged() => CanExecuteChanged?.Invoke(this, System.EventArgs.Empty);
    }
}
