using UnityEngine;

[RequireComponent(typeof(Camera))]
public class VolumetricLight : MonoBehaviour {

    public int qulity = 2;
    public float halfFOV = 30f;
    public float Intensity = 1f;
    public Color vlColor;
    public Material shadowCasterMat = null;

    private RenderTexture lightDepthTexture = null;
    private Camera _lightCamera;
    private Camera renderCamera;

    public void Start()
    {
        renderCamera = GetComponent<Camera>();
        renderCamera.cullingMask = 1 << LayerMask.NameToLayer("ShadowCaster");
        renderCamera.backgroundColor = Color.white;
        renderCamera.enabled = false;
        renderCamera.allowMSAA = false;
        if (!renderCamera.targetTexture)
        {
            renderCamera.targetTexture = lightDepthTexture = CreateTextureForLight(renderCamera);
        }
    }

    void Update()
    {
        GetLightDepth();
    }

    private void GetLightDepth()
    {
        if (shadowCasterMat == null)
        {
            return;
        }

        if (!_lightCamera)
        {
            _lightCamera = renderCamera;
            _lightCamera.aspect = 1;
        }

        halfFOV = Mathf.Clamp(halfFOV, 0, 60);
        float cosVolumetricLightAngle = Mathf.Cos(halfFOV * 2 * Mathf.PI / 360f);

        _lightCamera.fieldOfView = halfFOV * 2;
        _lightCamera.RenderWithShader(shadowCasterMat.shader, "");

        Intensity = Mathf.Max(0, Intensity);
        Vector4 volumetricLightPos = new Vector4(transform.position.x, transform.position.y, transform.position.z, Intensity);
        Vector3 vlightLocalForward = new Vector3(0, 0, 1);
        Vector3 vlightForward = transform.TransformVector(vlightLocalForward);
        Vector4 volumetricLightForward = new Vector4(vlightForward.x, vlightForward.y, vlightForward.z, cosVolumetricLightAngle);

        Shader.SetGlobalVector("_VolumetricLightForward", volumetricLightForward);
        // 传递体积光世界位置， w 为被照亮物体的强度
        Shader.SetGlobalVector("_VolumetricLightPos", volumetricLightPos);
        Shader.SetGlobalColor("_VolumetricLightColor", vlColor);
        Shader.SetGlobalTexture("_VLightDepthTex", lightDepthTexture);
        Matrix4x4 projectionMatrix = GL.GetGPUProjectionMatrix(_lightCamera.projectionMatrix, false);
        Shader.SetGlobalMatrix("_WorldToShadow", projectionMatrix * _lightCamera.worldToCameraMatrix);
    }

    private RenderTexture CreateTextureForLight(Camera cam)
    {
        RenderTexture rt = new RenderTexture(1024 * qulity, 1024 * qulity, 24, RenderTextureFormat.RFloat);
        rt.hideFlags = HideFlags.DontSave;
        rt.useMipMap = false;

        return rt;
    }
}
