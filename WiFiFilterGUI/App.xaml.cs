using System.Configuration;
using System.Data;
using System.Windows;

namespace WiFiFilterGUI;

/// <summary>
/// Interaction logic for App.xaml
/// </summary>
public partial class App : Application
{
    protected override void OnStartup(StartupEventArgs e)
    {
        base.OnStartup(e);
        
        AppDomain.CurrentDomain.UnhandledException += (s, args) =>
        {
            LogException(args.ExceptionObject as Exception, "AppDomain.UnhandledException");
        };

        DispatcherUnhandledException += (s, args) =>
        {
            LogException(args.Exception, "DispatcherUnhandledException");
            args.Handled = true;
        };

        try
        {
            // Ensure we can write to the directory
            System.IO.File.AppendAllText("debug_log.txt", $"Application starting at {System.DateTime.Now}\n");
        }
        catch { }
    }

    private void LogException(Exception ex, string source)
    {
        try
        {
            string message = $"[{System.DateTime.Now}] {source}: {ex?.Message}\n{ex?.StackTrace}\n\n";
            System.IO.File.AppendAllText("debug_log.txt", message);
            MessageBox.Show($"An error occurred: {ex?.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
        }
        catch { }
    }
}

