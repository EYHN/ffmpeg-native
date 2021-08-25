using System;
using System.IO;
using System.Net.Http;
using System.Text;
using ICSharpCode.SharpZipLib.GZip;
using ICSharpCode.SharpZipLib.Tar;
using Nuke.Common;
using Nuke.Common.Execution;
using Nuke.Common.IO;
using Nuke.Common.Tooling;
using Nuke.Common.Tools.NuGet;
using Nuke.Common.Utilities.Collections;
using static Nuke.Common.IO.FileSystemTasks;
using static Nuke.Common.Tools.NuGet.NuGetTasks;

[UnsetVisualStudioEnvironmentVariables]
public class Packager : NukeBuild
{
    public static int Main() => Execute<Packager>(x => x.All);

    AbsolutePath TargetsDirectory => RootDirectory / "targets";
    AbsolutePath PackingDirectory => RootDirectory / "packager/native/pack";
    AbsolutePath DownloadsDirectory => RootDirectory / "downloads";

    string ReleaseTag  => Environment.GetEnvironmentVariable("RELEASE_TAG") ?? "4.4.0";

    string ReleaseVersion => Environment.GetEnvironmentVariable("RELEASE_VERSION") ?? "4.4.0";

    string[] NuGetArchitectures => new[]
    {
        "win-x64",
        "linux-x64",
        "osx-x64"
    };

    Target Clean => _ => _
        .Executes(() =>
        {
            EnsureCleanDirectory(PackingDirectory);
            EnsureCleanDirectory(DownloadsDirectory);
            EnsureCleanDirectory(TargetsDirectory);
        });

    Target DownloadBinaries => _ => _
        .DependsOn(Clean)
        .Executes(async () =>
        {
            var client = new HttpClient();

            foreach (var architecture in NuGetArchitectures)
            {
                var fileName = $"{architecture}.tar.gz";
                var tarball =
                    new Uri(
                        $"https://github.com/EYHN/ffmpeg-native/releases/download/{ReleaseTag}/{fileName}");

                var filePath = DownloadsDirectory / fileName;
                if (!File.Exists(filePath))
                {
                    Logger.Info(filePath + " not in download directory. Downloading now ...");
                    EnsureExistingDirectory(DownloadsDirectory);
                    var response = await client.GetAsync(tarball);
                    await using var fs = new FileStream(filePath, FileMode.CreateNew);
                    await response.Content.CopyToAsync(fs);
                }

                var tempDir = PackingDirectory / "temp";

                Logger.Info($"Uncompressing {fileName} ...");
                await using (var inStream = File.OpenRead(filePath))
                await using (var gzipStream = new GZipInputStream(inStream))
                using (var tarArchive = TarArchive.CreateInputTarArchive(gzipStream, Encoding.UTF8))
                {
                    tarArchive.ExtractContents(tempDir);
                }

                var dllPackDir = PackingDirectory / architecture;
                Console.WriteLine(dllPackDir);
                EnsureExistingDirectory(dllPackDir);

                tempDir.GlobFiles("**/*.dll", "**/*.so*", "**/*.dylib")
                    .ForEach(f => CopyFileToDirectory(f, dllPackDir));

                DeleteDirectory(tempDir);
            }
        });

    Target CreateNativeNuGetPackages => _ => _
        .DependsOn(DownloadBinaries)
        .DependsOn(Clean)
        .Executes(() =>
        {
            // Build the architecture specific packages
            NuGetPack(c => c
                .SetVersion(ReleaseVersion)
                .SetOutputDirectory(TargetsDirectory)
                .AddProperty("NoWarn", "NU5128")
                .CombineWith(NuGetArchitectures,
                    (_, architecture) =>
                        _.SetTargetPath(RootDirectory / "packager/native/FFmpeg.Native." + architecture + ".nuspec")));

            // Build the all-in-one package, which depends on the previous packages.
            NuGetPack(c => c
                .SetTargetPath(RootDirectory / "packager/native/FFmpeg.Native.nuspec")
                .SetVersion(ReleaseVersion)
                .SetOutputDirectory(TargetsDirectory)
                .AddProperty("NoWarn", "NU5128"));
        });

    Target All => _ => _
        .DependsOn(CreateNativeNuGetPackages);
}