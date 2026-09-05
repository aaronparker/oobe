function Set-ScreenResolution {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [int]$Width,
        [Parameter(Mandatory)]
        [int]$Height,
        [ValidateRange(100, 500)]
        [int]$Scale
    )
    $code = @"
using System;
using System.Runtime.InteropServices;

public class ScreenResolutionV2 {
    private const int ENUM_CURRENT_SETTINGS = -1;
    private const int DM_PELSWIDTH = 0x00080000;
    private const int DM_PELSHEIGHT = 0x00100000;
    private const uint QDC_ONLY_ACTIVE_PATHS = 0x00000002;
    private const uint DISPLAYCONFIG_DEVICE_INFO_GET_DPI_SCALE = 0xFFFFFFFD;
    private const uint DISPLAYCONFIG_DEVICE_INFO_SET_DPI_SCALE = 0xFFFFFFFC;

    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    private static extern bool EnumDisplaySettings(string deviceName, int modeNum, ref DEVMODE devMode);

    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    private static extern int ChangeDisplaySettings(ref DEVMODE devMode, int flags);

    [DllImport("user32.dll")]
    private static extern int GetDisplayConfigBufferSizes(uint flags, out uint pathCount, out uint modeCount);

    [DllImport("user32.dll")]
    private static extern int QueryDisplayConfig(uint flags, ref uint pathCount,
        [Out] DISPLAYCONFIG_PATH_INFO[] paths, ref uint modeCount,
        [Out] DISPLAYCONFIG_MODE_INFO[] modes, IntPtr topologyId);

    [DllImport("user32.dll")]
    private static extern int DisplayConfigGetDeviceInfo(ref DISPLAYCONFIG_SOURCE_DPI_SCALE_GET request);

    [DllImport("user32.dll")]
    private static extern int DisplayConfigSetDeviceInfo(ref DISPLAYCONFIG_SOURCE_DPI_SCALE_SET request);

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    private struct DEVMODE {
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] public string dmDeviceName;
        public short dmSpecVersion;
        public short dmDriverVersion;
        public short dmSize;
        public short dmDriverExtra;
        public int dmFields;
        public int dmPositionX;
        public int dmPositionY;
        public int dmDisplayOrientation;
        public int dmDisplayFixedOutput;
        public short dmColor;
        public short dmDuplex;
        public short dmYResolution;
        public short dmTTOption;
        public short dmCollate;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] public string dmFormName;
        public short dmLogPixels;
        public int dmBitsPerPel;
        public int dmPelsWidth;
        public int dmPelsHeight;
        public int dmDisplayFlags;
        public int dmDisplayFrequency;
        public int dmICMMethod;
        public int dmICMIntent;
        public int dmMediaType;
        public int dmDitherType;
        public int dmReserved1;
        public int dmReserved2;
        public int dmPanningWidth;
        public int dmPanningHeight;
    }

    [StructLayout(LayoutKind.Sequential)]
    private struct LUID { public uint LowPart; public int HighPart; }

    [StructLayout(LayoutKind.Sequential)]
    private struct DISPLAYCONFIG_RATIONAL { public uint Numerator; public uint Denominator; }

    [StructLayout(LayoutKind.Sequential)]
    private struct DISPLAYCONFIG_PATH_SOURCE_INFO {
        public LUID adapterId;
        public uint id;
        public uint modeInfoIdx;
        public uint statusFlags;
    }

    [StructLayout(LayoutKind.Sequential)]
    private struct DISPLAYCONFIG_PATH_TARGET_INFO {
        public LUID adapterId;
        public uint id;
        public uint modeInfoIdx;
        public uint outputTechnology;
        public uint rotation;
        public uint scaling;
        public DISPLAYCONFIG_RATIONAL refreshRate;
        public uint scanLineOrdering;
        [MarshalAs(UnmanagedType.Bool)] public bool targetAvailable;
        public uint statusFlags;
    }

    [StructLayout(LayoutKind.Sequential)]
    private struct DISPLAYCONFIG_PATH_INFO {
        public DISPLAYCONFIG_PATH_SOURCE_INFO sourceInfo;
        public DISPLAYCONFIG_PATH_TARGET_INFO targetInfo;
        public uint flags;
    }

    [StructLayout(LayoutKind.Explicit, Size = 64)]
    private struct DISPLAYCONFIG_MODE_INFO { }

    [StructLayout(LayoutKind.Sequential)]
    private struct DISPLAYCONFIG_DEVICE_INFO_HEADER {
        public uint type;
        public uint size;
        public LUID adapterId;
        public uint id;
    }

    [StructLayout(LayoutKind.Sequential)]
    private struct DISPLAYCONFIG_SOURCE_DPI_SCALE_GET {
        public DISPLAYCONFIG_DEVICE_INFO_HEADER header;
        public int minScaleRel;
        public int curScaleRel;
        public int maxScaleRel;
    }

    [StructLayout(LayoutKind.Sequential)]
    private struct DISPLAYCONFIG_SOURCE_DPI_SCALE_SET {
        public DISPLAYCONFIG_DEVICE_INFO_HEADER header;
        public int scaleRel;
    }

    public static string ChangeResolution(int width, int height, int scale) {
        DEVMODE mode = new DEVMODE();
        mode.dmSize = (short)Marshal.SizeOf(typeof(DEVMODE));
        if (!EnumDisplaySettings(null, ENUM_CURRENT_SETTINGS, ref mode))
            throw new InvalidOperationException("Unable to read the current display settings.");

        mode.dmPelsWidth = width;
        mode.dmPelsHeight = height;
        mode.dmFields = DM_PELSWIDTH | DM_PELSHEIGHT;
        int resolutionResult = ChangeDisplaySettings(ref mode, 0);
        if (resolutionResult != 0)
            throw new InvalidOperationException("Changing resolution failed with code " + resolutionResult + ".");

        if (scale > 0)
            SetScale(scale);

        return scale > 0
            ? String.Format("Resolution set to {0}x{1}; scaling set to {2}%.", width, height, scale)
            : String.Format("Resolution set to {0}x{1}.", width, height);
    }

    private static void SetScale(int scale) {
        uint pathCount;
        uint modeCount;
        int result = GetDisplayConfigBufferSizes(QDC_ONLY_ACTIVE_PATHS, out pathCount, out modeCount);
        if (result != 0)
            throw new InvalidOperationException("Unable to query display configuration (" + result + ").");

        DISPLAYCONFIG_PATH_INFO[] paths = new DISPLAYCONFIG_PATH_INFO[pathCount];
        DISPLAYCONFIG_MODE_INFO[] modes = new DISPLAYCONFIG_MODE_INFO[modeCount];
        result = QueryDisplayConfig(QDC_ONLY_ACTIVE_PATHS, ref pathCount, paths, ref modeCount, modes, IntPtr.Zero);
        if (result != 0 || pathCount == 0)
            throw new InvalidOperationException("Unable to read the active display path (" + result + ").");

        DISPLAYCONFIG_SOURCE_DPI_SCALE_GET current = new DISPLAYCONFIG_SOURCE_DPI_SCALE_GET();
        current.header.type = DISPLAYCONFIG_DEVICE_INFO_GET_DPI_SCALE;
        current.header.size = (uint)Marshal.SizeOf(typeof(DISPLAYCONFIG_SOURCE_DPI_SCALE_GET));
        current.header.adapterId = paths[0].sourceInfo.adapterId;
        current.header.id = paths[0].sourceInfo.id;
        result = DisplayConfigGetDeviceInfo(ref current);
        if (result != 0)
            throw new InvalidOperationException("Unable to read supported scaling values (" + result + ").");

        int[] scaleValues = { 100, 125, 150, 175, 200, 225, 250, 300, 350, 400, 450, 500 };
        int requestedIndex = Array.IndexOf(scaleValues, scale);
        int recommendedIndex = -current.minScaleRel;
        int relativeScale = requestedIndex - recommendedIndex;
        if (requestedIndex < 0 || relativeScale < current.minScaleRel || relativeScale > current.maxScaleRel)
            throw new ArgumentOutOfRangeException("scale", "The requested scaling value is not supported by the primary display.");

        DISPLAYCONFIG_SOURCE_DPI_SCALE_SET request = new DISPLAYCONFIG_SOURCE_DPI_SCALE_SET();
        request.header.type = DISPLAYCONFIG_DEVICE_INFO_SET_DPI_SCALE;
        request.header.size = (uint)Marshal.SizeOf(typeof(DISPLAYCONFIG_SOURCE_DPI_SCALE_SET));
        request.header.adapterId = paths[0].sourceInfo.adapterId;
        request.header.id = paths[0].sourceInfo.id;
        request.scaleRel = relativeScale;
        result = DisplayConfigSetDeviceInfo(ref request);
        if (result != 0)
            throw new InvalidOperationException("Changing display scaling failed with code " + result + ".");
    }
}
"@
    if (-not ('ScreenResolutionV2' -as [type])) {
        Add-Type -TypeDefinition $code
    }
    $requestedScale = if ($PSBoundParameters.ContainsKey('Scale')) { $Scale } else { 0 }
    [ScreenResolutionV2]::ChangeResolution($Width, $Height, $requestedScale)
}

