using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;

namespace Hdrp10 {

public enum Format { Rec709, Rec2020_ST2084 }

[System.Serializable]
public sealed class FormatParameter : VolumeParameter<Format>{}

[System.Serializable]
[VolumeComponentMenu("HDRP10/Format Conversion")]
public sealed class FormatConversion
  : CustomPostProcessVolumeComponent, IPostProcessComponent
{
    public FormatParameter format = new FormatParameter();
    public FloatParameter paperWhite = new FloatParameter(160);

    Material _material;

    const string ShaderPath = "Hidden/Hdrp10/FormatConversion";

    public bool IsActive()
      => _material != null && format.value != Format.Rec709;

    public override CustomPostProcessInjectionPoint injectionPoint
      => CustomPostProcessInjectionPoint.AfterPostProcess;

    public override void Setup()
      => _material = CoreUtils.CreateEngineMaterial(ShaderPath);

    public override void Render
      (CommandBuffer cmd, HDCamera camera, RTHandle srcRT, RTHandle destRT)
    {
        if (_material == null) return;
        _material.SetTexture("_InputTexture", srcRT);
        _material.SetFloat("_PaperWhite", paperWhite.value);
        HDUtils.DrawFullScreen(cmd, _material, destRT);
    }

    public override void Cleanup()
      => CoreUtils.Destroy(_material);
}

} // namespace Hdrp10
