using System.Text.Json.Nodes;
using Cocona;

static IEnumerable<string> TailFrom(string file)
{
    using (var reader = File.OpenText(file))
    {
        while (true)
        {
            var line = reader.ReadLine();
            if (reader.BaseStream.Length < reader.BaseStream.Position)
                reader.BaseStream.Seek(0, SeekOrigin.Begin);

            if (line != null) yield return line;
            else Thread.Sleep(500);
        }
    }
}

static async void ComputeLogLine(string outputDirectory, string line)
{
    JsonNode? obj;
    try
    {
        obj = JsonNode.Parse(line);
    }
    catch (Exception e)
    {
        Console.Write(e.Message);
        return;
    }

    if (obj == null) return;
    var routerName = obj["RouterName"]?.ToString();

    await File.WriteAllTextAsync($"{outputDirectory}/{routerName}", $"{line}\n");
}

CoconaApp.Run((
    [Option('i', Description = "Path to access log file")]
    string logFilePath
    ,
    [Option('o', Description = "Path to output directory")]
    string outputDirectory
) =>
{
    if (!File.Exists(logFilePath))
    {
        Console.WriteLine("Input file not found");
        Environment.Exit(1);
    }

    if (!Directory.Exists(outputDirectory))
    {
        Console.WriteLine("Output directory not found");
        Environment.Exit(1);
    }

    foreach (var line in TailFrom(logFilePath)) ComputeLogLine(outputDirectory, line);
});