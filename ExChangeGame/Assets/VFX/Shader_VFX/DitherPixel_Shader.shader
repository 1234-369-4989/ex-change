Shader "DitherPixel"
{
    Properties
    {
        [NoScaleOffset]_Texture2D("Texture2D", 2D) = "white" {}
        _Albedo_Color("Albedo Color", Color) = (0, 0.7942071, 1, 0)
        _PixelSize("PixelSize", Float) = 20
        _Speed("Speed", Float) = 0
        _NoiseScale("NoiseScale", Float) = 15.26
        _DelayTime("DelayTime", Float) = 1
        _ClipTime("ClipTime", Float) = 0
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue"="Transparent"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
        
        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _CLUSTERED_RENDERING
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _ALPHATEST_ON 1
        #define _SPECULAR_SETUP 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
             float3 interp4 : INTERP4;
             float2 interp5 : INTERP5;
             float2 interp6 : INTERP6;
             float3 interp7 : INTERP7;
             float4 interp8 : INTERP8;
             float4 interp9 : INTERP9;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp5.xy =  input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.interp6.xy =  input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp7.xyz =  input.sh;
            #endif
            output.interp8.xyzw =  input.fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.interp9.xyzw =  input.shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.interp5.xy;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.interp6.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp7.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp8.xyzw;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.interp9.xyzw;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _PixelSize;
        float _Speed;
        float _NoiseScale;
        float _DelayTime;
        float _ClipTime;
        float4 _Texture2D_TexelSize;
        float4 _Albedo_Color;
        CBUFFER_END
        
        // Object and Global properties
        TEXTURE2D(_Texture2D);
        SAMPLER(sampler_Texture2D);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Floor_float4(float4 In, out float4 Out)
        {
            Out = floor(In);
        }
        
        void Unity_Truncate_float(float In, out float Out)
        {
            Out = trunc(In);
        }
        
        void Unity_Divide_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A / B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_RadialShear_float(float2 UV, float2 Center, float2 Strength, float2 Offset, out float2 Out)
        {
            float2 delta = UV - Center;
            float delta2 = dot(delta.xy, delta.xy);
            float2 delta_offset = delta2 * Strength;
            Out = UV + float2(delta.y, -delta.x) * delta_offset + Offset;
        }
        
        
        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            float angle = dot(uv, float2(12.9898, 78.233));
            #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
            #endif
            return frac(sin(angle)*43758.5453);
        }
        
        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }
        
        
        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
        
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);
        
            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;
        
            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            Out = t;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float3 Specular;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_8644611fff744ae4becb69c5781fbba3_Out_0 = IN.uv0;
            float _Property_f9d2955ecfe144dbbeaf77fe52998288_Out_0 = _PixelSize;
            float _Float_6c180475e60843f3957ea88e596932d0_Out_0 = _Property_f9d2955ecfe144dbbeaf77fe52998288_Out_0;
            float4 _Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2;
            Unity_Multiply_float4_float4(_UV_8644611fff744ae4becb69c5781fbba3_Out_0, (_Float_6c180475e60843f3957ea88e596932d0_Out_0.xxxx), _Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2);
            float4 _Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1;
            Unity_Floor_float4(_Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2, _Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1);
            float _Truncate_f6835003e66c47669c2cb177aba706fa_Out_1;
            Unity_Truncate_float(_Float_6c180475e60843f3957ea88e596932d0_Out_0, _Truncate_f6835003e66c47669c2cb177aba706fa_Out_1);
            float4 _Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2;
            Unity_Divide_float4(_Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1, (_Truncate_f6835003e66c47669c2cb177aba706fa_Out_1.xxxx), _Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2);
            float _Divide_fd2fa06b391f45b391c0f12db273137f_Out_2;
            Unity_Divide_float(0.45, _Float_6c180475e60843f3957ea88e596932d0_Out_0, _Divide_fd2fa06b391f45b391c0f12db273137f_Out_2);
            float2 _TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3;
            Unity_TilingAndOffset_float((_Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2.xy), float2 (1, 1), (_Divide_fd2fa06b391f45b391c0f12db273137f_Out_2.xx), _TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3);
            float _Property_a3a75f49f4024f68a306a2f1cd130404_Out_0 = _Speed;
            float _Multiply_49ab0549de734441baa0badd6d8f6424_Out_2;
            Unity_Multiply_float_float(_Property_a3a75f49f4024f68a306a2f1cd130404_Out_0, IN.TimeParameters.x, _Multiply_49ab0549de734441baa0badd6d8f6424_Out_2);
            float2 _RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4;
            Unity_RadialShear_float(_TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3, float2 (0.5, 0.5), float2 (3.15, 10), (_Multiply_49ab0549de734441baa0badd6d8f6424_Out_2.xx), _RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4);
            float _Property_914ddfeffef649e0a197e87e6d4e8d23_Out_0 = _NoiseScale;
            float _SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2;
            Unity_SimpleNoise_float(_RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4, _Property_914ddfeffef649e0a197e87e6d4e8d23_Out_0, _SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2);
            float _Property_4c2407561bc741da9ac554d5c089d653_Out_0 = _ClipTime;
            float _Property_29a2394af39f435089fa0fea9ec9d1aa_Out_0 = _ClipTime;
            float _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2;
            Unity_Add_float(1, _Property_29a2394af39f435089fa0fea9ec9d1aa_Out_0, _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2);
            float2 _Vector2_3666d2cbdbff465990d5c84b040d175e_Out_0 = float2(0, _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2);
            float _Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3;
            Unity_Remap_float(_Property_4c2407561bc741da9ac554d5c089d653_Out_0, float2 (0, 1), _Vector2_3666d2cbdbff465990d5c84b040d175e_Out_0, _Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3);
            float _Property_69571a462025446792a26e20568505f8_Out_0 = _DelayTime;
            float _Subtract_659417884a4f451bb21103f3b415e655_Out_2;
            Unity_Subtract_float(_Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3, _Property_69571a462025446792a26e20568505f8_Out_0, _Subtract_659417884a4f451bb21103f3b415e655_Out_2);
            float _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2;
            Unity_Step_float(_SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2, _Subtract_659417884a4f451bb21103f3b415e655_Out_2, _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2);
            surface.BaseColor = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = float3(0, 0, 0);
            surface.Specular = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = 1;
            surface.AlphaClipThreshold = _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }
        
        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_GBUFFER
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _ALPHATEST_ON 1
        #define _SPECULAR_SETUP 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
             float3 interp4 : INTERP4;
             float2 interp5 : INTERP5;
             float2 interp6 : INTERP6;
             float3 interp7 : INTERP7;
             float4 interp8 : INTERP8;
             float4 interp9 : INTERP9;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp5.xy =  input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.interp6.xy =  input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp7.xyz =  input.sh;
            #endif
            output.interp8.xyzw =  input.fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.interp9.xyzw =  input.shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.interp5.xy;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.interp6.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp7.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp8.xyzw;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.interp9.xyzw;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _PixelSize;
        float _Speed;
        float _NoiseScale;
        float _DelayTime;
        float _ClipTime;
        float4 _Texture2D_TexelSize;
        float4 _Albedo_Color;
        CBUFFER_END
        
        // Object and Global properties
        TEXTURE2D(_Texture2D);
        SAMPLER(sampler_Texture2D);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Floor_float4(float4 In, out float4 Out)
        {
            Out = floor(In);
        }
        
        void Unity_Truncate_float(float In, out float Out)
        {
            Out = trunc(In);
        }
        
        void Unity_Divide_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A / B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_RadialShear_float(float2 UV, float2 Center, float2 Strength, float2 Offset, out float2 Out)
        {
            float2 delta = UV - Center;
            float delta2 = dot(delta.xy, delta.xy);
            float2 delta_offset = delta2 * Strength;
            Out = UV + float2(delta.y, -delta.x) * delta_offset + Offset;
        }
        
        
        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            float angle = dot(uv, float2(12.9898, 78.233));
            #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
            #endif
            return frac(sin(angle)*43758.5453);
        }
        
        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }
        
        
        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
        
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);
        
            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;
        
            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            Out = t;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float3 Specular;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_8644611fff744ae4becb69c5781fbba3_Out_0 = IN.uv0;
            float _Property_f9d2955ecfe144dbbeaf77fe52998288_Out_0 = _PixelSize;
            float _Float_6c180475e60843f3957ea88e596932d0_Out_0 = _Property_f9d2955ecfe144dbbeaf77fe52998288_Out_0;
            float4 _Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2;
            Unity_Multiply_float4_float4(_UV_8644611fff744ae4becb69c5781fbba3_Out_0, (_Float_6c180475e60843f3957ea88e596932d0_Out_0.xxxx), _Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2);
            float4 _Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1;
            Unity_Floor_float4(_Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2, _Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1);
            float _Truncate_f6835003e66c47669c2cb177aba706fa_Out_1;
            Unity_Truncate_float(_Float_6c180475e60843f3957ea88e596932d0_Out_0, _Truncate_f6835003e66c47669c2cb177aba706fa_Out_1);
            float4 _Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2;
            Unity_Divide_float4(_Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1, (_Truncate_f6835003e66c47669c2cb177aba706fa_Out_1.xxxx), _Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2);
            float _Divide_fd2fa06b391f45b391c0f12db273137f_Out_2;
            Unity_Divide_float(0.45, _Float_6c180475e60843f3957ea88e596932d0_Out_0, _Divide_fd2fa06b391f45b391c0f12db273137f_Out_2);
            float2 _TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3;
            Unity_TilingAndOffset_float((_Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2.xy), float2 (1, 1), (_Divide_fd2fa06b391f45b391c0f12db273137f_Out_2.xx), _TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3);
            float _Property_a3a75f49f4024f68a306a2f1cd130404_Out_0 = _Speed;
            float _Multiply_49ab0549de734441baa0badd6d8f6424_Out_2;
            Unity_Multiply_float_float(_Property_a3a75f49f4024f68a306a2f1cd130404_Out_0, IN.TimeParameters.x, _Multiply_49ab0549de734441baa0badd6d8f6424_Out_2);
            float2 _RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4;
            Unity_RadialShear_float(_TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3, float2 (0.5, 0.5), float2 (3.15, 10), (_Multiply_49ab0549de734441baa0badd6d8f6424_Out_2.xx), _RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4);
            float _Property_914ddfeffef649e0a197e87e6d4e8d23_Out_0 = _NoiseScale;
            float _SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2;
            Unity_SimpleNoise_float(_RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4, _Property_914ddfeffef649e0a197e87e6d4e8d23_Out_0, _SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2);
            float _Property_4c2407561bc741da9ac554d5c089d653_Out_0 = _ClipTime;
            float _Property_29a2394af39f435089fa0fea9ec9d1aa_Out_0 = _ClipTime;
            float _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2;
            Unity_Add_float(1, _Property_29a2394af39f435089fa0fea9ec9d1aa_Out_0, _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2);
            float2 _Vector2_3666d2cbdbff465990d5c84b040d175e_Out_0 = float2(0, _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2);
            float _Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3;
            Unity_Remap_float(_Property_4c2407561bc741da9ac554d5c089d653_Out_0, float2 (0, 1), _Vector2_3666d2cbdbff465990d5c84b040d175e_Out_0, _Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3);
            float _Property_69571a462025446792a26e20568505f8_Out_0 = _DelayTime;
            float _Subtract_659417884a4f451bb21103f3b415e655_Out_2;
            Unity_Subtract_float(_Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3, _Property_69571a462025446792a26e20568505f8_Out_0, _Subtract_659417884a4f451bb21103f3b415e655_Out_2);
            float _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2;
            Unity_Step_float(_SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2, _Subtract_659417884a4f451bb21103f3b415e655_Out_2, _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2);
            surface.BaseColor = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = float3(0, 0, 0);
            surface.Specular = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = 1;
            surface.AlphaClipThreshold = _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float4 interp1 : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _PixelSize;
        float _Speed;
        float _NoiseScale;
        float _DelayTime;
        float _ClipTime;
        float4 _Texture2D_TexelSize;
        float4 _Albedo_Color;
        CBUFFER_END
        
        // Object and Global properties
        TEXTURE2D(_Texture2D);
        SAMPLER(sampler_Texture2D);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Floor_float4(float4 In, out float4 Out)
        {
            Out = floor(In);
        }
        
        void Unity_Truncate_float(float In, out float Out)
        {
            Out = trunc(In);
        }
        
        void Unity_Divide_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A / B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_RadialShear_float(float2 UV, float2 Center, float2 Strength, float2 Offset, out float2 Out)
        {
            float2 delta = UV - Center;
            float delta2 = dot(delta.xy, delta.xy);
            float2 delta_offset = delta2 * Strength;
            Out = UV + float2(delta.y, -delta.x) * delta_offset + Offset;
        }
        
        
        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            float angle = dot(uv, float2(12.9898, 78.233));
            #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
            #endif
            return frac(sin(angle)*43758.5453);
        }
        
        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }
        
        
        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
        
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);
        
            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;
        
            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            Out = t;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_8644611fff744ae4becb69c5781fbba3_Out_0 = IN.uv0;
            float _Property_f9d2955ecfe144dbbeaf77fe52998288_Out_0 = _PixelSize;
            float _Float_6c180475e60843f3957ea88e596932d0_Out_0 = _Property_f9d2955ecfe144dbbeaf77fe52998288_Out_0;
            float4 _Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2;
            Unity_Multiply_float4_float4(_UV_8644611fff744ae4becb69c5781fbba3_Out_0, (_Float_6c180475e60843f3957ea88e596932d0_Out_0.xxxx), _Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2);
            float4 _Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1;
            Unity_Floor_float4(_Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2, _Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1);
            float _Truncate_f6835003e66c47669c2cb177aba706fa_Out_1;
            Unity_Truncate_float(_Float_6c180475e60843f3957ea88e596932d0_Out_0, _Truncate_f6835003e66c47669c2cb177aba706fa_Out_1);
            float4 _Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2;
            Unity_Divide_float4(_Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1, (_Truncate_f6835003e66c47669c2cb177aba706fa_Out_1.xxxx), _Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2);
            float _Divide_fd2fa06b391f45b391c0f12db273137f_Out_2;
            Unity_Divide_float(0.45, _Float_6c180475e60843f3957ea88e596932d0_Out_0, _Divide_fd2fa06b391f45b391c0f12db273137f_Out_2);
            float2 _TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3;
            Unity_TilingAndOffset_float((_Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2.xy), float2 (1, 1), (_Divide_fd2fa06b391f45b391c0f12db273137f_Out_2.xx), _TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3);
            float _Property_a3a75f49f4024f68a306a2f1cd130404_Out_0 = _Speed;
            float _Multiply_49ab0549de734441baa0badd6d8f6424_Out_2;
            Unity_Multiply_float_float(_Property_a3a75f49f4024f68a306a2f1cd130404_Out_0, IN.TimeParameters.x, _Multiply_49ab0549de734441baa0badd6d8f6424_Out_2);
            float2 _RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4;
            Unity_RadialShear_float(_TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3, float2 (0.5, 0.5), float2 (3.15, 10), (_Multiply_49ab0549de734441baa0badd6d8f6424_Out_2.xx), _RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4);
            float _Property_914ddfeffef649e0a197e87e6d4e8d23_Out_0 = _NoiseScale;
            float _SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2;
            Unity_SimpleNoise_float(_RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4, _Property_914ddfeffef649e0a197e87e6d4e8d23_Out_0, _SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2);
            float _Property_4c2407561bc741da9ac554d5c089d653_Out_0 = _ClipTime;
            float _Property_29a2394af39f435089fa0fea9ec9d1aa_Out_0 = _ClipTime;
            float _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2;
            Unity_Add_float(1, _Property_29a2394af39f435089fa0fea9ec9d1aa_Out_0, _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2);
            float2 _Vector2_3666d2cbdbff465990d5c84b040d175e_Out_0 = float2(0, _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2);
            float _Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3;
            Unity_Remap_float(_Property_4c2407561bc741da9ac554d5c089d653_Out_0, float2 (0, 1), _Vector2_3666d2cbdbff465990d5c84b040d175e_Out_0, _Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3);
            float _Property_69571a462025446792a26e20568505f8_Out_0 = _DelayTime;
            float _Subtract_659417884a4f451bb21103f3b415e655_Out_2;
            Unity_Subtract_float(_Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3, _Property_69571a462025446792a26e20568505f8_Out_0, _Subtract_659417884a4f451bb21103f3b415e655_Out_2);
            float _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2;
            Unity_Step_float(_SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2, _Subtract_659417884a4f451bb21103f3b415e655_Out_2, _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2);
            surface.Alpha = 1;
            surface.AlphaClipThreshold = _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALS
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float4 interp1 : INTERP1;
             float4 interp2 : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyzw =  input.tangentWS;
            output.interp2.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.interp0.xyz;
            output.tangentWS = input.interp1.xyzw;
            output.texCoord0 = input.interp2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _PixelSize;
        float _Speed;
        float _NoiseScale;
        float _DelayTime;
        float _ClipTime;
        float4 _Texture2D_TexelSize;
        float4 _Albedo_Color;
        CBUFFER_END
        
        // Object and Global properties
        TEXTURE2D(_Texture2D);
        SAMPLER(sampler_Texture2D);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Floor_float4(float4 In, out float4 Out)
        {
            Out = floor(In);
        }
        
        void Unity_Truncate_float(float In, out float Out)
        {
            Out = trunc(In);
        }
        
        void Unity_Divide_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A / B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_RadialShear_float(float2 UV, float2 Center, float2 Strength, float2 Offset, out float2 Out)
        {
            float2 delta = UV - Center;
            float delta2 = dot(delta.xy, delta.xy);
            float2 delta_offset = delta2 * Strength;
            Out = UV + float2(delta.y, -delta.x) * delta_offset + Offset;
        }
        
        
        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            float angle = dot(uv, float2(12.9898, 78.233));
            #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
            #endif
            return frac(sin(angle)*43758.5453);
        }
        
        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }
        
        
        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
        
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);
        
            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;
        
            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            Out = t;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_8644611fff744ae4becb69c5781fbba3_Out_0 = IN.uv0;
            float _Property_f9d2955ecfe144dbbeaf77fe52998288_Out_0 = _PixelSize;
            float _Float_6c180475e60843f3957ea88e596932d0_Out_0 = _Property_f9d2955ecfe144dbbeaf77fe52998288_Out_0;
            float4 _Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2;
            Unity_Multiply_float4_float4(_UV_8644611fff744ae4becb69c5781fbba3_Out_0, (_Float_6c180475e60843f3957ea88e596932d0_Out_0.xxxx), _Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2);
            float4 _Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1;
            Unity_Floor_float4(_Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2, _Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1);
            float _Truncate_f6835003e66c47669c2cb177aba706fa_Out_1;
            Unity_Truncate_float(_Float_6c180475e60843f3957ea88e596932d0_Out_0, _Truncate_f6835003e66c47669c2cb177aba706fa_Out_1);
            float4 _Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2;
            Unity_Divide_float4(_Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1, (_Truncate_f6835003e66c47669c2cb177aba706fa_Out_1.xxxx), _Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2);
            float _Divide_fd2fa06b391f45b391c0f12db273137f_Out_2;
            Unity_Divide_float(0.45, _Float_6c180475e60843f3957ea88e596932d0_Out_0, _Divide_fd2fa06b391f45b391c0f12db273137f_Out_2);
            float2 _TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3;
            Unity_TilingAndOffset_float((_Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2.xy), float2 (1, 1), (_Divide_fd2fa06b391f45b391c0f12db273137f_Out_2.xx), _TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3);
            float _Property_a3a75f49f4024f68a306a2f1cd130404_Out_0 = _Speed;
            float _Multiply_49ab0549de734441baa0badd6d8f6424_Out_2;
            Unity_Multiply_float_float(_Property_a3a75f49f4024f68a306a2f1cd130404_Out_0, IN.TimeParameters.x, _Multiply_49ab0549de734441baa0badd6d8f6424_Out_2);
            float2 _RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4;
            Unity_RadialShear_float(_TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3, float2 (0.5, 0.5), float2 (3.15, 10), (_Multiply_49ab0549de734441baa0badd6d8f6424_Out_2.xx), _RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4);
            float _Property_914ddfeffef649e0a197e87e6d4e8d23_Out_0 = _NoiseScale;
            float _SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2;
            Unity_SimpleNoise_float(_RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4, _Property_914ddfeffef649e0a197e87e6d4e8d23_Out_0, _SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2);
            float _Property_4c2407561bc741da9ac554d5c089d653_Out_0 = _ClipTime;
            float _Property_29a2394af39f435089fa0fea9ec9d1aa_Out_0 = _ClipTime;
            float _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2;
            Unity_Add_float(1, _Property_29a2394af39f435089fa0fea9ec9d1aa_Out_0, _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2);
            float2 _Vector2_3666d2cbdbff465990d5c84b040d175e_Out_0 = float2(0, _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2);
            float _Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3;
            Unity_Remap_float(_Property_4c2407561bc741da9ac554d5c089d653_Out_0, float2 (0, 1), _Vector2_3666d2cbdbff465990d5c84b040d175e_Out_0, _Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3);
            float _Property_69571a462025446792a26e20568505f8_Out_0 = _DelayTime;
            float _Subtract_659417884a4f451bb21103f3b415e655_Out_2;
            Unity_Subtract_float(_Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3, _Property_69571a462025446792a26e20568505f8_Out_0, _Subtract_659417884a4f451bb21103f3b415e655_Out_2);
            float _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2;
            Unity_Step_float(_SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2, _Subtract_659417884a4f451bb21103f3b415e655_Out_2, _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = 1;
            surface.AlphaClipThreshold = _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma shader_feature _ EDITOR_VISUALIZATION
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_TEXCOORD2
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define _FOG_FRAGMENT 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
             float4 texCoord1;
             float4 texCoord2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 interp0 : INTERP0;
             float4 interp1 : INTERP1;
             float4 interp2 : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            output.interp1.xyzw =  input.texCoord1;
            output.interp2.xyzw =  input.texCoord2;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            output.texCoord1 = input.interp1.xyzw;
            output.texCoord2 = input.interp2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _PixelSize;
        float _Speed;
        float _NoiseScale;
        float _DelayTime;
        float _ClipTime;
        float4 _Texture2D_TexelSize;
        float4 _Albedo_Color;
        CBUFFER_END
        
        // Object and Global properties
        TEXTURE2D(_Texture2D);
        SAMPLER(sampler_Texture2D);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Floor_float4(float4 In, out float4 Out)
        {
            Out = floor(In);
        }
        
        void Unity_Truncate_float(float In, out float Out)
        {
            Out = trunc(In);
        }
        
        void Unity_Divide_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A / B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_RadialShear_float(float2 UV, float2 Center, float2 Strength, float2 Offset, out float2 Out)
        {
            float2 delta = UV - Center;
            float delta2 = dot(delta.xy, delta.xy);
            float2 delta_offset = delta2 * Strength;
            Out = UV + float2(delta.y, -delta.x) * delta_offset + Offset;
        }
        
        
        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            float angle = dot(uv, float2(12.9898, 78.233));
            #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
            #endif
            return frac(sin(angle)*43758.5453);
        }
        
        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }
        
        
        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
        
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);
        
            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;
        
            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            Out = t;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_8644611fff744ae4becb69c5781fbba3_Out_0 = IN.uv0;
            float _Property_f9d2955ecfe144dbbeaf77fe52998288_Out_0 = _PixelSize;
            float _Float_6c180475e60843f3957ea88e596932d0_Out_0 = _Property_f9d2955ecfe144dbbeaf77fe52998288_Out_0;
            float4 _Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2;
            Unity_Multiply_float4_float4(_UV_8644611fff744ae4becb69c5781fbba3_Out_0, (_Float_6c180475e60843f3957ea88e596932d0_Out_0.xxxx), _Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2);
            float4 _Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1;
            Unity_Floor_float4(_Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2, _Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1);
            float _Truncate_f6835003e66c47669c2cb177aba706fa_Out_1;
            Unity_Truncate_float(_Float_6c180475e60843f3957ea88e596932d0_Out_0, _Truncate_f6835003e66c47669c2cb177aba706fa_Out_1);
            float4 _Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2;
            Unity_Divide_float4(_Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1, (_Truncate_f6835003e66c47669c2cb177aba706fa_Out_1.xxxx), _Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2);
            float _Divide_fd2fa06b391f45b391c0f12db273137f_Out_2;
            Unity_Divide_float(0.45, _Float_6c180475e60843f3957ea88e596932d0_Out_0, _Divide_fd2fa06b391f45b391c0f12db273137f_Out_2);
            float2 _TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3;
            Unity_TilingAndOffset_float((_Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2.xy), float2 (1, 1), (_Divide_fd2fa06b391f45b391c0f12db273137f_Out_2.xx), _TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3);
            float _Property_a3a75f49f4024f68a306a2f1cd130404_Out_0 = _Speed;
            float _Multiply_49ab0549de734441baa0badd6d8f6424_Out_2;
            Unity_Multiply_float_float(_Property_a3a75f49f4024f68a306a2f1cd130404_Out_0, IN.TimeParameters.x, _Multiply_49ab0549de734441baa0badd6d8f6424_Out_2);
            float2 _RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4;
            Unity_RadialShear_float(_TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3, float2 (0.5, 0.5), float2 (3.15, 10), (_Multiply_49ab0549de734441baa0badd6d8f6424_Out_2.xx), _RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4);
            float _Property_914ddfeffef649e0a197e87e6d4e8d23_Out_0 = _NoiseScale;
            float _SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2;
            Unity_SimpleNoise_float(_RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4, _Property_914ddfeffef649e0a197e87e6d4e8d23_Out_0, _SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2);
            float _Property_4c2407561bc741da9ac554d5c089d653_Out_0 = _ClipTime;
            float _Property_29a2394af39f435089fa0fea9ec9d1aa_Out_0 = _ClipTime;
            float _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2;
            Unity_Add_float(1, _Property_29a2394af39f435089fa0fea9ec9d1aa_Out_0, _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2);
            float2 _Vector2_3666d2cbdbff465990d5c84b040d175e_Out_0 = float2(0, _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2);
            float _Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3;
            Unity_Remap_float(_Property_4c2407561bc741da9ac554d5c089d653_Out_0, float2 (0, 1), _Vector2_3666d2cbdbff465990d5c84b040d175e_Out_0, _Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3);
            float _Property_69571a462025446792a26e20568505f8_Out_0 = _DelayTime;
            float _Subtract_659417884a4f451bb21103f3b415e655_Out_2;
            Unity_Subtract_float(_Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3, _Property_69571a462025446792a26e20568505f8_Out_0, _Subtract_659417884a4f451bb21103f3b415e655_Out_2);
            float _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2;
            Unity_Step_float(_SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2, _Subtract_659417884a4f451bb21103f3b415e655_Out_2, _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2);
            surface.BaseColor = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
            surface.Emission = float3(0, 0, 0);
            surface.Alpha = 1;
            surface.AlphaClipThreshold = _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _PixelSize;
        float _Speed;
        float _NoiseScale;
        float _DelayTime;
        float _ClipTime;
        float4 _Texture2D_TexelSize;
        float4 _Albedo_Color;
        CBUFFER_END
        
        // Object and Global properties
        TEXTURE2D(_Texture2D);
        SAMPLER(sampler_Texture2D);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Floor_float4(float4 In, out float4 Out)
        {
            Out = floor(In);
        }
        
        void Unity_Truncate_float(float In, out float Out)
        {
            Out = trunc(In);
        }
        
        void Unity_Divide_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A / B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_RadialShear_float(float2 UV, float2 Center, float2 Strength, float2 Offset, out float2 Out)
        {
            float2 delta = UV - Center;
            float delta2 = dot(delta.xy, delta.xy);
            float2 delta_offset = delta2 * Strength;
            Out = UV + float2(delta.y, -delta.x) * delta_offset + Offset;
        }
        
        
        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            float angle = dot(uv, float2(12.9898, 78.233));
            #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
            #endif
            return frac(sin(angle)*43758.5453);
        }
        
        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }
        
        
        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
        
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);
        
            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;
        
            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            Out = t;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_8644611fff744ae4becb69c5781fbba3_Out_0 = IN.uv0;
            float _Property_f9d2955ecfe144dbbeaf77fe52998288_Out_0 = _PixelSize;
            float _Float_6c180475e60843f3957ea88e596932d0_Out_0 = _Property_f9d2955ecfe144dbbeaf77fe52998288_Out_0;
            float4 _Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2;
            Unity_Multiply_float4_float4(_UV_8644611fff744ae4becb69c5781fbba3_Out_0, (_Float_6c180475e60843f3957ea88e596932d0_Out_0.xxxx), _Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2);
            float4 _Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1;
            Unity_Floor_float4(_Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2, _Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1);
            float _Truncate_f6835003e66c47669c2cb177aba706fa_Out_1;
            Unity_Truncate_float(_Float_6c180475e60843f3957ea88e596932d0_Out_0, _Truncate_f6835003e66c47669c2cb177aba706fa_Out_1);
            float4 _Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2;
            Unity_Divide_float4(_Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1, (_Truncate_f6835003e66c47669c2cb177aba706fa_Out_1.xxxx), _Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2);
            float _Divide_fd2fa06b391f45b391c0f12db273137f_Out_2;
            Unity_Divide_float(0.45, _Float_6c180475e60843f3957ea88e596932d0_Out_0, _Divide_fd2fa06b391f45b391c0f12db273137f_Out_2);
            float2 _TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3;
            Unity_TilingAndOffset_float((_Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2.xy), float2 (1, 1), (_Divide_fd2fa06b391f45b391c0f12db273137f_Out_2.xx), _TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3);
            float _Property_a3a75f49f4024f68a306a2f1cd130404_Out_0 = _Speed;
            float _Multiply_49ab0549de734441baa0badd6d8f6424_Out_2;
            Unity_Multiply_float_float(_Property_a3a75f49f4024f68a306a2f1cd130404_Out_0, IN.TimeParameters.x, _Multiply_49ab0549de734441baa0badd6d8f6424_Out_2);
            float2 _RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4;
            Unity_RadialShear_float(_TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3, float2 (0.5, 0.5), float2 (3.15, 10), (_Multiply_49ab0549de734441baa0badd6d8f6424_Out_2.xx), _RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4);
            float _Property_914ddfeffef649e0a197e87e6d4e8d23_Out_0 = _NoiseScale;
            float _SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2;
            Unity_SimpleNoise_float(_RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4, _Property_914ddfeffef649e0a197e87e6d4e8d23_Out_0, _SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2);
            float _Property_4c2407561bc741da9ac554d5c089d653_Out_0 = _ClipTime;
            float _Property_29a2394af39f435089fa0fea9ec9d1aa_Out_0 = _ClipTime;
            float _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2;
            Unity_Add_float(1, _Property_29a2394af39f435089fa0fea9ec9d1aa_Out_0, _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2);
            float2 _Vector2_3666d2cbdbff465990d5c84b040d175e_Out_0 = float2(0, _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2);
            float _Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3;
            Unity_Remap_float(_Property_4c2407561bc741da9ac554d5c089d653_Out_0, float2 (0, 1), _Vector2_3666d2cbdbff465990d5c84b040d175e_Out_0, _Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3);
            float _Property_69571a462025446792a26e20568505f8_Out_0 = _DelayTime;
            float _Subtract_659417884a4f451bb21103f3b415e655_Out_2;
            Unity_Subtract_float(_Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3, _Property_69571a462025446792a26e20568505f8_Out_0, _Subtract_659417884a4f451bb21103f3b415e655_Out_2);
            float _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2;
            Unity_Step_float(_SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2, _Subtract_659417884a4f451bb21103f3b415e655_Out_2, _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2);
            surface.Alpha = 1;
            surface.AlphaClipThreshold = _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Back
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _PixelSize;
        float _Speed;
        float _NoiseScale;
        float _DelayTime;
        float _ClipTime;
        float4 _Texture2D_TexelSize;
        float4 _Albedo_Color;
        CBUFFER_END
        
        // Object and Global properties
        TEXTURE2D(_Texture2D);
        SAMPLER(sampler_Texture2D);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Floor_float4(float4 In, out float4 Out)
        {
            Out = floor(In);
        }
        
        void Unity_Truncate_float(float In, out float Out)
        {
            Out = trunc(In);
        }
        
        void Unity_Divide_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A / B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_RadialShear_float(float2 UV, float2 Center, float2 Strength, float2 Offset, out float2 Out)
        {
            float2 delta = UV - Center;
            float delta2 = dot(delta.xy, delta.xy);
            float2 delta_offset = delta2 * Strength;
            Out = UV + float2(delta.y, -delta.x) * delta_offset + Offset;
        }
        
        
        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            float angle = dot(uv, float2(12.9898, 78.233));
            #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
            #endif
            return frac(sin(angle)*43758.5453);
        }
        
        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }
        
        
        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
        
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);
        
            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;
        
            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            Out = t;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_8644611fff744ae4becb69c5781fbba3_Out_0 = IN.uv0;
            float _Property_f9d2955ecfe144dbbeaf77fe52998288_Out_0 = _PixelSize;
            float _Float_6c180475e60843f3957ea88e596932d0_Out_0 = _Property_f9d2955ecfe144dbbeaf77fe52998288_Out_0;
            float4 _Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2;
            Unity_Multiply_float4_float4(_UV_8644611fff744ae4becb69c5781fbba3_Out_0, (_Float_6c180475e60843f3957ea88e596932d0_Out_0.xxxx), _Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2);
            float4 _Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1;
            Unity_Floor_float4(_Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2, _Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1);
            float _Truncate_f6835003e66c47669c2cb177aba706fa_Out_1;
            Unity_Truncate_float(_Float_6c180475e60843f3957ea88e596932d0_Out_0, _Truncate_f6835003e66c47669c2cb177aba706fa_Out_1);
            float4 _Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2;
            Unity_Divide_float4(_Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1, (_Truncate_f6835003e66c47669c2cb177aba706fa_Out_1.xxxx), _Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2);
            float _Divide_fd2fa06b391f45b391c0f12db273137f_Out_2;
            Unity_Divide_float(0.45, _Float_6c180475e60843f3957ea88e596932d0_Out_0, _Divide_fd2fa06b391f45b391c0f12db273137f_Out_2);
            float2 _TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3;
            Unity_TilingAndOffset_float((_Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2.xy), float2 (1, 1), (_Divide_fd2fa06b391f45b391c0f12db273137f_Out_2.xx), _TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3);
            float _Property_a3a75f49f4024f68a306a2f1cd130404_Out_0 = _Speed;
            float _Multiply_49ab0549de734441baa0badd6d8f6424_Out_2;
            Unity_Multiply_float_float(_Property_a3a75f49f4024f68a306a2f1cd130404_Out_0, IN.TimeParameters.x, _Multiply_49ab0549de734441baa0badd6d8f6424_Out_2);
            float2 _RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4;
            Unity_RadialShear_float(_TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3, float2 (0.5, 0.5), float2 (3.15, 10), (_Multiply_49ab0549de734441baa0badd6d8f6424_Out_2.xx), _RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4);
            float _Property_914ddfeffef649e0a197e87e6d4e8d23_Out_0 = _NoiseScale;
            float _SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2;
            Unity_SimpleNoise_float(_RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4, _Property_914ddfeffef649e0a197e87e6d4e8d23_Out_0, _SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2);
            float _Property_4c2407561bc741da9ac554d5c089d653_Out_0 = _ClipTime;
            float _Property_29a2394af39f435089fa0fea9ec9d1aa_Out_0 = _ClipTime;
            float _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2;
            Unity_Add_float(1, _Property_29a2394af39f435089fa0fea9ec9d1aa_Out_0, _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2);
            float2 _Vector2_3666d2cbdbff465990d5c84b040d175e_Out_0 = float2(0, _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2);
            float _Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3;
            Unity_Remap_float(_Property_4c2407561bc741da9ac554d5c089d653_Out_0, float2 (0, 1), _Vector2_3666d2cbdbff465990d5c84b040d175e_Out_0, _Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3);
            float _Property_69571a462025446792a26e20568505f8_Out_0 = _DelayTime;
            float _Subtract_659417884a4f451bb21103f3b415e655_Out_2;
            Unity_Subtract_float(_Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3, _Property_69571a462025446792a26e20568505f8_Out_0, _Subtract_659417884a4f451bb21103f3b415e655_Out_2);
            float _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2;
            Unity_Step_float(_SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2, _Subtract_659417884a4f451bb21103f3b415e655_Out_2, _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2);
            surface.Alpha = 1;
            surface.AlphaClipThreshold = _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }
        
        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _PixelSize;
        float _Speed;
        float _NoiseScale;
        float _DelayTime;
        float _ClipTime;
        float4 _Texture2D_TexelSize;
        float4 _Albedo_Color;
        CBUFFER_END
        
        // Object and Global properties
        TEXTURE2D(_Texture2D);
        SAMPLER(sampler_Texture2D);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Floor_float4(float4 In, out float4 Out)
        {
            Out = floor(In);
        }
        
        void Unity_Truncate_float(float In, out float Out)
        {
            Out = trunc(In);
        }
        
        void Unity_Divide_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A / B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_RadialShear_float(float2 UV, float2 Center, float2 Strength, float2 Offset, out float2 Out)
        {
            float2 delta = UV - Center;
            float delta2 = dot(delta.xy, delta.xy);
            float2 delta_offset = delta2 * Strength;
            Out = UV + float2(delta.y, -delta.x) * delta_offset + Offset;
        }
        
        
        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            float angle = dot(uv, float2(12.9898, 78.233));
            #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
            #endif
            return frac(sin(angle)*43758.5453);
        }
        
        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }
        
        
        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
        
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);
        
            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;
        
            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            Out = t;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_8644611fff744ae4becb69c5781fbba3_Out_0 = IN.uv0;
            float _Property_f9d2955ecfe144dbbeaf77fe52998288_Out_0 = _PixelSize;
            float _Float_6c180475e60843f3957ea88e596932d0_Out_0 = _Property_f9d2955ecfe144dbbeaf77fe52998288_Out_0;
            float4 _Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2;
            Unity_Multiply_float4_float4(_UV_8644611fff744ae4becb69c5781fbba3_Out_0, (_Float_6c180475e60843f3957ea88e596932d0_Out_0.xxxx), _Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2);
            float4 _Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1;
            Unity_Floor_float4(_Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2, _Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1);
            float _Truncate_f6835003e66c47669c2cb177aba706fa_Out_1;
            Unity_Truncate_float(_Float_6c180475e60843f3957ea88e596932d0_Out_0, _Truncate_f6835003e66c47669c2cb177aba706fa_Out_1);
            float4 _Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2;
            Unity_Divide_float4(_Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1, (_Truncate_f6835003e66c47669c2cb177aba706fa_Out_1.xxxx), _Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2);
            float _Divide_fd2fa06b391f45b391c0f12db273137f_Out_2;
            Unity_Divide_float(0.45, _Float_6c180475e60843f3957ea88e596932d0_Out_0, _Divide_fd2fa06b391f45b391c0f12db273137f_Out_2);
            float2 _TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3;
            Unity_TilingAndOffset_float((_Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2.xy), float2 (1, 1), (_Divide_fd2fa06b391f45b391c0f12db273137f_Out_2.xx), _TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3);
            float _Property_a3a75f49f4024f68a306a2f1cd130404_Out_0 = _Speed;
            float _Multiply_49ab0549de734441baa0badd6d8f6424_Out_2;
            Unity_Multiply_float_float(_Property_a3a75f49f4024f68a306a2f1cd130404_Out_0, IN.TimeParameters.x, _Multiply_49ab0549de734441baa0badd6d8f6424_Out_2);
            float2 _RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4;
            Unity_RadialShear_float(_TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3, float2 (0.5, 0.5), float2 (3.15, 10), (_Multiply_49ab0549de734441baa0badd6d8f6424_Out_2.xx), _RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4);
            float _Property_914ddfeffef649e0a197e87e6d4e8d23_Out_0 = _NoiseScale;
            float _SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2;
            Unity_SimpleNoise_float(_RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4, _Property_914ddfeffef649e0a197e87e6d4e8d23_Out_0, _SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2);
            float _Property_4c2407561bc741da9ac554d5c089d653_Out_0 = _ClipTime;
            float _Property_29a2394af39f435089fa0fea9ec9d1aa_Out_0 = _ClipTime;
            float _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2;
            Unity_Add_float(1, _Property_29a2394af39f435089fa0fea9ec9d1aa_Out_0, _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2);
            float2 _Vector2_3666d2cbdbff465990d5c84b040d175e_Out_0 = float2(0, _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2);
            float _Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3;
            Unity_Remap_float(_Property_4c2407561bc741da9ac554d5c089d653_Out_0, float2 (0, 1), _Vector2_3666d2cbdbff465990d5c84b040d175e_Out_0, _Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3);
            float _Property_69571a462025446792a26e20568505f8_Out_0 = _DelayTime;
            float _Subtract_659417884a4f451bb21103f3b415e655_Out_2;
            Unity_Subtract_float(_Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3, _Property_69571a462025446792a26e20568505f8_Out_0, _Subtract_659417884a4f451bb21103f3b415e655_Out_2);
            float _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2;
            Unity_Step_float(_SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2, _Subtract_659417884a4f451bb21103f3b415e655_Out_2, _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2);
            surface.BaseColor = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
            surface.Alpha = 1;
            surface.AlphaClipThreshold = _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue"="Transparent"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
        
        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _CLUSTERED_RENDERING
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _ALPHATEST_ON 1
        #define _SPECULAR_SETUP 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
             float3 interp4 : INTERP4;
             float2 interp5 : INTERP5;
             float2 interp6 : INTERP6;
             float3 interp7 : INTERP7;
             float4 interp8 : INTERP8;
             float4 interp9 : INTERP9;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp5.xy =  input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.interp6.xy =  input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp7.xyz =  input.sh;
            #endif
            output.interp8.xyzw =  input.fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.interp9.xyzw =  input.shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.interp5.xy;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.interp6.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp7.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp8.xyzw;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.interp9.xyzw;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _PixelSize;
        float _Speed;
        float _NoiseScale;
        float _DelayTime;
        float _ClipTime;
        float4 _Texture2D_TexelSize;
        float4 _Albedo_Color;
        CBUFFER_END
        
        // Object and Global properties
        TEXTURE2D(_Texture2D);
        SAMPLER(sampler_Texture2D);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Floor_float4(float4 In, out float4 Out)
        {
            Out = floor(In);
        }
        
        void Unity_Truncate_float(float In, out float Out)
        {
            Out = trunc(In);
        }
        
        void Unity_Divide_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A / B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_RadialShear_float(float2 UV, float2 Center, float2 Strength, float2 Offset, out float2 Out)
        {
            float2 delta = UV - Center;
            float delta2 = dot(delta.xy, delta.xy);
            float2 delta_offset = delta2 * Strength;
            Out = UV + float2(delta.y, -delta.x) * delta_offset + Offset;
        }
        
        
        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            float angle = dot(uv, float2(12.9898, 78.233));
            #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
            #endif
            return frac(sin(angle)*43758.5453);
        }
        
        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }
        
        
        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
        
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);
        
            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;
        
            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            Out = t;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float3 Specular;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_8644611fff744ae4becb69c5781fbba3_Out_0 = IN.uv0;
            float _Property_f9d2955ecfe144dbbeaf77fe52998288_Out_0 = _PixelSize;
            float _Float_6c180475e60843f3957ea88e596932d0_Out_0 = _Property_f9d2955ecfe144dbbeaf77fe52998288_Out_0;
            float4 _Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2;
            Unity_Multiply_float4_float4(_UV_8644611fff744ae4becb69c5781fbba3_Out_0, (_Float_6c180475e60843f3957ea88e596932d0_Out_0.xxxx), _Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2);
            float4 _Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1;
            Unity_Floor_float4(_Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2, _Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1);
            float _Truncate_f6835003e66c47669c2cb177aba706fa_Out_1;
            Unity_Truncate_float(_Float_6c180475e60843f3957ea88e596932d0_Out_0, _Truncate_f6835003e66c47669c2cb177aba706fa_Out_1);
            float4 _Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2;
            Unity_Divide_float4(_Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1, (_Truncate_f6835003e66c47669c2cb177aba706fa_Out_1.xxxx), _Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2);
            float _Divide_fd2fa06b391f45b391c0f12db273137f_Out_2;
            Unity_Divide_float(0.45, _Float_6c180475e60843f3957ea88e596932d0_Out_0, _Divide_fd2fa06b391f45b391c0f12db273137f_Out_2);
            float2 _TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3;
            Unity_TilingAndOffset_float((_Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2.xy), float2 (1, 1), (_Divide_fd2fa06b391f45b391c0f12db273137f_Out_2.xx), _TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3);
            float _Property_a3a75f49f4024f68a306a2f1cd130404_Out_0 = _Speed;
            float _Multiply_49ab0549de734441baa0badd6d8f6424_Out_2;
            Unity_Multiply_float_float(_Property_a3a75f49f4024f68a306a2f1cd130404_Out_0, IN.TimeParameters.x, _Multiply_49ab0549de734441baa0badd6d8f6424_Out_2);
            float2 _RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4;
            Unity_RadialShear_float(_TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3, float2 (0.5, 0.5), float2 (3.15, 10), (_Multiply_49ab0549de734441baa0badd6d8f6424_Out_2.xx), _RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4);
            float _Property_914ddfeffef649e0a197e87e6d4e8d23_Out_0 = _NoiseScale;
            float _SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2;
            Unity_SimpleNoise_float(_RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4, _Property_914ddfeffef649e0a197e87e6d4e8d23_Out_0, _SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2);
            float _Property_4c2407561bc741da9ac554d5c089d653_Out_0 = _ClipTime;
            float _Property_29a2394af39f435089fa0fea9ec9d1aa_Out_0 = _ClipTime;
            float _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2;
            Unity_Add_float(1, _Property_29a2394af39f435089fa0fea9ec9d1aa_Out_0, _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2);
            float2 _Vector2_3666d2cbdbff465990d5c84b040d175e_Out_0 = float2(0, _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2);
            float _Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3;
            Unity_Remap_float(_Property_4c2407561bc741da9ac554d5c089d653_Out_0, float2 (0, 1), _Vector2_3666d2cbdbff465990d5c84b040d175e_Out_0, _Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3);
            float _Property_69571a462025446792a26e20568505f8_Out_0 = _DelayTime;
            float _Subtract_659417884a4f451bb21103f3b415e655_Out_2;
            Unity_Subtract_float(_Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3, _Property_69571a462025446792a26e20568505f8_Out_0, _Subtract_659417884a4f451bb21103f3b415e655_Out_2);
            float _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2;
            Unity_Step_float(_SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2, _Subtract_659417884a4f451bb21103f3b415e655_Out_2, _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2);
            surface.BaseColor = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = float3(0, 0, 0);
            surface.Specular = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = 1;
            surface.AlphaClipThreshold = _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float4 interp1 : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _PixelSize;
        float _Speed;
        float _NoiseScale;
        float _DelayTime;
        float _ClipTime;
        float4 _Texture2D_TexelSize;
        float4 _Albedo_Color;
        CBUFFER_END
        
        // Object and Global properties
        TEXTURE2D(_Texture2D);
        SAMPLER(sampler_Texture2D);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Floor_float4(float4 In, out float4 Out)
        {
            Out = floor(In);
        }
        
        void Unity_Truncate_float(float In, out float Out)
        {
            Out = trunc(In);
        }
        
        void Unity_Divide_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A / B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_RadialShear_float(float2 UV, float2 Center, float2 Strength, float2 Offset, out float2 Out)
        {
            float2 delta = UV - Center;
            float delta2 = dot(delta.xy, delta.xy);
            float2 delta_offset = delta2 * Strength;
            Out = UV + float2(delta.y, -delta.x) * delta_offset + Offset;
        }
        
        
        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            float angle = dot(uv, float2(12.9898, 78.233));
            #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
            #endif
            return frac(sin(angle)*43758.5453);
        }
        
        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }
        
        
        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
        
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);
        
            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;
        
            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            Out = t;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_8644611fff744ae4becb69c5781fbba3_Out_0 = IN.uv0;
            float _Property_f9d2955ecfe144dbbeaf77fe52998288_Out_0 = _PixelSize;
            float _Float_6c180475e60843f3957ea88e596932d0_Out_0 = _Property_f9d2955ecfe144dbbeaf77fe52998288_Out_0;
            float4 _Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2;
            Unity_Multiply_float4_float4(_UV_8644611fff744ae4becb69c5781fbba3_Out_0, (_Float_6c180475e60843f3957ea88e596932d0_Out_0.xxxx), _Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2);
            float4 _Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1;
            Unity_Floor_float4(_Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2, _Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1);
            float _Truncate_f6835003e66c47669c2cb177aba706fa_Out_1;
            Unity_Truncate_float(_Float_6c180475e60843f3957ea88e596932d0_Out_0, _Truncate_f6835003e66c47669c2cb177aba706fa_Out_1);
            float4 _Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2;
            Unity_Divide_float4(_Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1, (_Truncate_f6835003e66c47669c2cb177aba706fa_Out_1.xxxx), _Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2);
            float _Divide_fd2fa06b391f45b391c0f12db273137f_Out_2;
            Unity_Divide_float(0.45, _Float_6c180475e60843f3957ea88e596932d0_Out_0, _Divide_fd2fa06b391f45b391c0f12db273137f_Out_2);
            float2 _TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3;
            Unity_TilingAndOffset_float((_Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2.xy), float2 (1, 1), (_Divide_fd2fa06b391f45b391c0f12db273137f_Out_2.xx), _TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3);
            float _Property_a3a75f49f4024f68a306a2f1cd130404_Out_0 = _Speed;
            float _Multiply_49ab0549de734441baa0badd6d8f6424_Out_2;
            Unity_Multiply_float_float(_Property_a3a75f49f4024f68a306a2f1cd130404_Out_0, IN.TimeParameters.x, _Multiply_49ab0549de734441baa0badd6d8f6424_Out_2);
            float2 _RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4;
            Unity_RadialShear_float(_TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3, float2 (0.5, 0.5), float2 (3.15, 10), (_Multiply_49ab0549de734441baa0badd6d8f6424_Out_2.xx), _RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4);
            float _Property_914ddfeffef649e0a197e87e6d4e8d23_Out_0 = _NoiseScale;
            float _SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2;
            Unity_SimpleNoise_float(_RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4, _Property_914ddfeffef649e0a197e87e6d4e8d23_Out_0, _SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2);
            float _Property_4c2407561bc741da9ac554d5c089d653_Out_0 = _ClipTime;
            float _Property_29a2394af39f435089fa0fea9ec9d1aa_Out_0 = _ClipTime;
            float _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2;
            Unity_Add_float(1, _Property_29a2394af39f435089fa0fea9ec9d1aa_Out_0, _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2);
            float2 _Vector2_3666d2cbdbff465990d5c84b040d175e_Out_0 = float2(0, _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2);
            float _Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3;
            Unity_Remap_float(_Property_4c2407561bc741da9ac554d5c089d653_Out_0, float2 (0, 1), _Vector2_3666d2cbdbff465990d5c84b040d175e_Out_0, _Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3);
            float _Property_69571a462025446792a26e20568505f8_Out_0 = _DelayTime;
            float _Subtract_659417884a4f451bb21103f3b415e655_Out_2;
            Unity_Subtract_float(_Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3, _Property_69571a462025446792a26e20568505f8_Out_0, _Subtract_659417884a4f451bb21103f3b415e655_Out_2);
            float _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2;
            Unity_Step_float(_SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2, _Subtract_659417884a4f451bb21103f3b415e655_Out_2, _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2);
            surface.Alpha = 1;
            surface.AlphaClipThreshold = _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALS
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float4 interp1 : INTERP1;
             float4 interp2 : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyzw =  input.tangentWS;
            output.interp2.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.interp0.xyz;
            output.tangentWS = input.interp1.xyzw;
            output.texCoord0 = input.interp2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _PixelSize;
        float _Speed;
        float _NoiseScale;
        float _DelayTime;
        float _ClipTime;
        float4 _Texture2D_TexelSize;
        float4 _Albedo_Color;
        CBUFFER_END
        
        // Object and Global properties
        TEXTURE2D(_Texture2D);
        SAMPLER(sampler_Texture2D);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Floor_float4(float4 In, out float4 Out)
        {
            Out = floor(In);
        }
        
        void Unity_Truncate_float(float In, out float Out)
        {
            Out = trunc(In);
        }
        
        void Unity_Divide_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A / B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_RadialShear_float(float2 UV, float2 Center, float2 Strength, float2 Offset, out float2 Out)
        {
            float2 delta = UV - Center;
            float delta2 = dot(delta.xy, delta.xy);
            float2 delta_offset = delta2 * Strength;
            Out = UV + float2(delta.y, -delta.x) * delta_offset + Offset;
        }
        
        
        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            float angle = dot(uv, float2(12.9898, 78.233));
            #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
            #endif
            return frac(sin(angle)*43758.5453);
        }
        
        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }
        
        
        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
        
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);
        
            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;
        
            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            Out = t;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_8644611fff744ae4becb69c5781fbba3_Out_0 = IN.uv0;
            float _Property_f9d2955ecfe144dbbeaf77fe52998288_Out_0 = _PixelSize;
            float _Float_6c180475e60843f3957ea88e596932d0_Out_0 = _Property_f9d2955ecfe144dbbeaf77fe52998288_Out_0;
            float4 _Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2;
            Unity_Multiply_float4_float4(_UV_8644611fff744ae4becb69c5781fbba3_Out_0, (_Float_6c180475e60843f3957ea88e596932d0_Out_0.xxxx), _Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2);
            float4 _Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1;
            Unity_Floor_float4(_Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2, _Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1);
            float _Truncate_f6835003e66c47669c2cb177aba706fa_Out_1;
            Unity_Truncate_float(_Float_6c180475e60843f3957ea88e596932d0_Out_0, _Truncate_f6835003e66c47669c2cb177aba706fa_Out_1);
            float4 _Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2;
            Unity_Divide_float4(_Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1, (_Truncate_f6835003e66c47669c2cb177aba706fa_Out_1.xxxx), _Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2);
            float _Divide_fd2fa06b391f45b391c0f12db273137f_Out_2;
            Unity_Divide_float(0.45, _Float_6c180475e60843f3957ea88e596932d0_Out_0, _Divide_fd2fa06b391f45b391c0f12db273137f_Out_2);
            float2 _TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3;
            Unity_TilingAndOffset_float((_Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2.xy), float2 (1, 1), (_Divide_fd2fa06b391f45b391c0f12db273137f_Out_2.xx), _TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3);
            float _Property_a3a75f49f4024f68a306a2f1cd130404_Out_0 = _Speed;
            float _Multiply_49ab0549de734441baa0badd6d8f6424_Out_2;
            Unity_Multiply_float_float(_Property_a3a75f49f4024f68a306a2f1cd130404_Out_0, IN.TimeParameters.x, _Multiply_49ab0549de734441baa0badd6d8f6424_Out_2);
            float2 _RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4;
            Unity_RadialShear_float(_TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3, float2 (0.5, 0.5), float2 (3.15, 10), (_Multiply_49ab0549de734441baa0badd6d8f6424_Out_2.xx), _RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4);
            float _Property_914ddfeffef649e0a197e87e6d4e8d23_Out_0 = _NoiseScale;
            float _SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2;
            Unity_SimpleNoise_float(_RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4, _Property_914ddfeffef649e0a197e87e6d4e8d23_Out_0, _SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2);
            float _Property_4c2407561bc741da9ac554d5c089d653_Out_0 = _ClipTime;
            float _Property_29a2394af39f435089fa0fea9ec9d1aa_Out_0 = _ClipTime;
            float _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2;
            Unity_Add_float(1, _Property_29a2394af39f435089fa0fea9ec9d1aa_Out_0, _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2);
            float2 _Vector2_3666d2cbdbff465990d5c84b040d175e_Out_0 = float2(0, _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2);
            float _Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3;
            Unity_Remap_float(_Property_4c2407561bc741da9ac554d5c089d653_Out_0, float2 (0, 1), _Vector2_3666d2cbdbff465990d5c84b040d175e_Out_0, _Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3);
            float _Property_69571a462025446792a26e20568505f8_Out_0 = _DelayTime;
            float _Subtract_659417884a4f451bb21103f3b415e655_Out_2;
            Unity_Subtract_float(_Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3, _Property_69571a462025446792a26e20568505f8_Out_0, _Subtract_659417884a4f451bb21103f3b415e655_Out_2);
            float _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2;
            Unity_Step_float(_SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2, _Subtract_659417884a4f451bb21103f3b415e655_Out_2, _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = 1;
            surface.AlphaClipThreshold = _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma shader_feature _ EDITOR_VISUALIZATION
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_TEXCOORD2
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define _FOG_FRAGMENT 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
             float4 texCoord1;
             float4 texCoord2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 interp0 : INTERP0;
             float4 interp1 : INTERP1;
             float4 interp2 : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            output.interp1.xyzw =  input.texCoord1;
            output.interp2.xyzw =  input.texCoord2;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            output.texCoord1 = input.interp1.xyzw;
            output.texCoord2 = input.interp2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _PixelSize;
        float _Speed;
        float _NoiseScale;
        float _DelayTime;
        float _ClipTime;
        float4 _Texture2D_TexelSize;
        float4 _Albedo_Color;
        CBUFFER_END
        
        // Object and Global properties
        TEXTURE2D(_Texture2D);
        SAMPLER(sampler_Texture2D);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Floor_float4(float4 In, out float4 Out)
        {
            Out = floor(In);
        }
        
        void Unity_Truncate_float(float In, out float Out)
        {
            Out = trunc(In);
        }
        
        void Unity_Divide_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A / B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_RadialShear_float(float2 UV, float2 Center, float2 Strength, float2 Offset, out float2 Out)
        {
            float2 delta = UV - Center;
            float delta2 = dot(delta.xy, delta.xy);
            float2 delta_offset = delta2 * Strength;
            Out = UV + float2(delta.y, -delta.x) * delta_offset + Offset;
        }
        
        
        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            float angle = dot(uv, float2(12.9898, 78.233));
            #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
            #endif
            return frac(sin(angle)*43758.5453);
        }
        
        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }
        
        
        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
        
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);
        
            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;
        
            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            Out = t;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_8644611fff744ae4becb69c5781fbba3_Out_0 = IN.uv0;
            float _Property_f9d2955ecfe144dbbeaf77fe52998288_Out_0 = _PixelSize;
            float _Float_6c180475e60843f3957ea88e596932d0_Out_0 = _Property_f9d2955ecfe144dbbeaf77fe52998288_Out_0;
            float4 _Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2;
            Unity_Multiply_float4_float4(_UV_8644611fff744ae4becb69c5781fbba3_Out_0, (_Float_6c180475e60843f3957ea88e596932d0_Out_0.xxxx), _Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2);
            float4 _Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1;
            Unity_Floor_float4(_Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2, _Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1);
            float _Truncate_f6835003e66c47669c2cb177aba706fa_Out_1;
            Unity_Truncate_float(_Float_6c180475e60843f3957ea88e596932d0_Out_0, _Truncate_f6835003e66c47669c2cb177aba706fa_Out_1);
            float4 _Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2;
            Unity_Divide_float4(_Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1, (_Truncate_f6835003e66c47669c2cb177aba706fa_Out_1.xxxx), _Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2);
            float _Divide_fd2fa06b391f45b391c0f12db273137f_Out_2;
            Unity_Divide_float(0.45, _Float_6c180475e60843f3957ea88e596932d0_Out_0, _Divide_fd2fa06b391f45b391c0f12db273137f_Out_2);
            float2 _TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3;
            Unity_TilingAndOffset_float((_Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2.xy), float2 (1, 1), (_Divide_fd2fa06b391f45b391c0f12db273137f_Out_2.xx), _TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3);
            float _Property_a3a75f49f4024f68a306a2f1cd130404_Out_0 = _Speed;
            float _Multiply_49ab0549de734441baa0badd6d8f6424_Out_2;
            Unity_Multiply_float_float(_Property_a3a75f49f4024f68a306a2f1cd130404_Out_0, IN.TimeParameters.x, _Multiply_49ab0549de734441baa0badd6d8f6424_Out_2);
            float2 _RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4;
            Unity_RadialShear_float(_TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3, float2 (0.5, 0.5), float2 (3.15, 10), (_Multiply_49ab0549de734441baa0badd6d8f6424_Out_2.xx), _RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4);
            float _Property_914ddfeffef649e0a197e87e6d4e8d23_Out_0 = _NoiseScale;
            float _SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2;
            Unity_SimpleNoise_float(_RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4, _Property_914ddfeffef649e0a197e87e6d4e8d23_Out_0, _SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2);
            float _Property_4c2407561bc741da9ac554d5c089d653_Out_0 = _ClipTime;
            float _Property_29a2394af39f435089fa0fea9ec9d1aa_Out_0 = _ClipTime;
            float _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2;
            Unity_Add_float(1, _Property_29a2394af39f435089fa0fea9ec9d1aa_Out_0, _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2);
            float2 _Vector2_3666d2cbdbff465990d5c84b040d175e_Out_0 = float2(0, _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2);
            float _Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3;
            Unity_Remap_float(_Property_4c2407561bc741da9ac554d5c089d653_Out_0, float2 (0, 1), _Vector2_3666d2cbdbff465990d5c84b040d175e_Out_0, _Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3);
            float _Property_69571a462025446792a26e20568505f8_Out_0 = _DelayTime;
            float _Subtract_659417884a4f451bb21103f3b415e655_Out_2;
            Unity_Subtract_float(_Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3, _Property_69571a462025446792a26e20568505f8_Out_0, _Subtract_659417884a4f451bb21103f3b415e655_Out_2);
            float _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2;
            Unity_Step_float(_SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2, _Subtract_659417884a4f451bb21103f3b415e655_Out_2, _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2);
            surface.BaseColor = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
            surface.Emission = float3(0, 0, 0);
            surface.Alpha = 1;
            surface.AlphaClipThreshold = _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _PixelSize;
        float _Speed;
        float _NoiseScale;
        float _DelayTime;
        float _ClipTime;
        float4 _Texture2D_TexelSize;
        float4 _Albedo_Color;
        CBUFFER_END
        
        // Object and Global properties
        TEXTURE2D(_Texture2D);
        SAMPLER(sampler_Texture2D);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Floor_float4(float4 In, out float4 Out)
        {
            Out = floor(In);
        }
        
        void Unity_Truncate_float(float In, out float Out)
        {
            Out = trunc(In);
        }
        
        void Unity_Divide_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A / B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_RadialShear_float(float2 UV, float2 Center, float2 Strength, float2 Offset, out float2 Out)
        {
            float2 delta = UV - Center;
            float delta2 = dot(delta.xy, delta.xy);
            float2 delta_offset = delta2 * Strength;
            Out = UV + float2(delta.y, -delta.x) * delta_offset + Offset;
        }
        
        
        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            float angle = dot(uv, float2(12.9898, 78.233));
            #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
            #endif
            return frac(sin(angle)*43758.5453);
        }
        
        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }
        
        
        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
        
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);
        
            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;
        
            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            Out = t;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_8644611fff744ae4becb69c5781fbba3_Out_0 = IN.uv0;
            float _Property_f9d2955ecfe144dbbeaf77fe52998288_Out_0 = _PixelSize;
            float _Float_6c180475e60843f3957ea88e596932d0_Out_0 = _Property_f9d2955ecfe144dbbeaf77fe52998288_Out_0;
            float4 _Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2;
            Unity_Multiply_float4_float4(_UV_8644611fff744ae4becb69c5781fbba3_Out_0, (_Float_6c180475e60843f3957ea88e596932d0_Out_0.xxxx), _Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2);
            float4 _Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1;
            Unity_Floor_float4(_Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2, _Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1);
            float _Truncate_f6835003e66c47669c2cb177aba706fa_Out_1;
            Unity_Truncate_float(_Float_6c180475e60843f3957ea88e596932d0_Out_0, _Truncate_f6835003e66c47669c2cb177aba706fa_Out_1);
            float4 _Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2;
            Unity_Divide_float4(_Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1, (_Truncate_f6835003e66c47669c2cb177aba706fa_Out_1.xxxx), _Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2);
            float _Divide_fd2fa06b391f45b391c0f12db273137f_Out_2;
            Unity_Divide_float(0.45, _Float_6c180475e60843f3957ea88e596932d0_Out_0, _Divide_fd2fa06b391f45b391c0f12db273137f_Out_2);
            float2 _TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3;
            Unity_TilingAndOffset_float((_Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2.xy), float2 (1, 1), (_Divide_fd2fa06b391f45b391c0f12db273137f_Out_2.xx), _TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3);
            float _Property_a3a75f49f4024f68a306a2f1cd130404_Out_0 = _Speed;
            float _Multiply_49ab0549de734441baa0badd6d8f6424_Out_2;
            Unity_Multiply_float_float(_Property_a3a75f49f4024f68a306a2f1cd130404_Out_0, IN.TimeParameters.x, _Multiply_49ab0549de734441baa0badd6d8f6424_Out_2);
            float2 _RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4;
            Unity_RadialShear_float(_TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3, float2 (0.5, 0.5), float2 (3.15, 10), (_Multiply_49ab0549de734441baa0badd6d8f6424_Out_2.xx), _RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4);
            float _Property_914ddfeffef649e0a197e87e6d4e8d23_Out_0 = _NoiseScale;
            float _SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2;
            Unity_SimpleNoise_float(_RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4, _Property_914ddfeffef649e0a197e87e6d4e8d23_Out_0, _SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2);
            float _Property_4c2407561bc741da9ac554d5c089d653_Out_0 = _ClipTime;
            float _Property_29a2394af39f435089fa0fea9ec9d1aa_Out_0 = _ClipTime;
            float _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2;
            Unity_Add_float(1, _Property_29a2394af39f435089fa0fea9ec9d1aa_Out_0, _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2);
            float2 _Vector2_3666d2cbdbff465990d5c84b040d175e_Out_0 = float2(0, _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2);
            float _Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3;
            Unity_Remap_float(_Property_4c2407561bc741da9ac554d5c089d653_Out_0, float2 (0, 1), _Vector2_3666d2cbdbff465990d5c84b040d175e_Out_0, _Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3);
            float _Property_69571a462025446792a26e20568505f8_Out_0 = _DelayTime;
            float _Subtract_659417884a4f451bb21103f3b415e655_Out_2;
            Unity_Subtract_float(_Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3, _Property_69571a462025446792a26e20568505f8_Out_0, _Subtract_659417884a4f451bb21103f3b415e655_Out_2);
            float _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2;
            Unity_Step_float(_SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2, _Subtract_659417884a4f451bb21103f3b415e655_Out_2, _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2);
            surface.Alpha = 1;
            surface.AlphaClipThreshold = _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Back
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _PixelSize;
        float _Speed;
        float _NoiseScale;
        float _DelayTime;
        float _ClipTime;
        float4 _Texture2D_TexelSize;
        float4 _Albedo_Color;
        CBUFFER_END
        
        // Object and Global properties
        TEXTURE2D(_Texture2D);
        SAMPLER(sampler_Texture2D);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Floor_float4(float4 In, out float4 Out)
        {
            Out = floor(In);
        }
        
        void Unity_Truncate_float(float In, out float Out)
        {
            Out = trunc(In);
        }
        
        void Unity_Divide_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A / B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_RadialShear_float(float2 UV, float2 Center, float2 Strength, float2 Offset, out float2 Out)
        {
            float2 delta = UV - Center;
            float delta2 = dot(delta.xy, delta.xy);
            float2 delta_offset = delta2 * Strength;
            Out = UV + float2(delta.y, -delta.x) * delta_offset + Offset;
        }
        
        
        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            float angle = dot(uv, float2(12.9898, 78.233));
            #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
            #endif
            return frac(sin(angle)*43758.5453);
        }
        
        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }
        
        
        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
        
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);
        
            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;
        
            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            Out = t;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_8644611fff744ae4becb69c5781fbba3_Out_0 = IN.uv0;
            float _Property_f9d2955ecfe144dbbeaf77fe52998288_Out_0 = _PixelSize;
            float _Float_6c180475e60843f3957ea88e596932d0_Out_0 = _Property_f9d2955ecfe144dbbeaf77fe52998288_Out_0;
            float4 _Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2;
            Unity_Multiply_float4_float4(_UV_8644611fff744ae4becb69c5781fbba3_Out_0, (_Float_6c180475e60843f3957ea88e596932d0_Out_0.xxxx), _Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2);
            float4 _Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1;
            Unity_Floor_float4(_Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2, _Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1);
            float _Truncate_f6835003e66c47669c2cb177aba706fa_Out_1;
            Unity_Truncate_float(_Float_6c180475e60843f3957ea88e596932d0_Out_0, _Truncate_f6835003e66c47669c2cb177aba706fa_Out_1);
            float4 _Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2;
            Unity_Divide_float4(_Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1, (_Truncate_f6835003e66c47669c2cb177aba706fa_Out_1.xxxx), _Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2);
            float _Divide_fd2fa06b391f45b391c0f12db273137f_Out_2;
            Unity_Divide_float(0.45, _Float_6c180475e60843f3957ea88e596932d0_Out_0, _Divide_fd2fa06b391f45b391c0f12db273137f_Out_2);
            float2 _TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3;
            Unity_TilingAndOffset_float((_Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2.xy), float2 (1, 1), (_Divide_fd2fa06b391f45b391c0f12db273137f_Out_2.xx), _TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3);
            float _Property_a3a75f49f4024f68a306a2f1cd130404_Out_0 = _Speed;
            float _Multiply_49ab0549de734441baa0badd6d8f6424_Out_2;
            Unity_Multiply_float_float(_Property_a3a75f49f4024f68a306a2f1cd130404_Out_0, IN.TimeParameters.x, _Multiply_49ab0549de734441baa0badd6d8f6424_Out_2);
            float2 _RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4;
            Unity_RadialShear_float(_TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3, float2 (0.5, 0.5), float2 (3.15, 10), (_Multiply_49ab0549de734441baa0badd6d8f6424_Out_2.xx), _RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4);
            float _Property_914ddfeffef649e0a197e87e6d4e8d23_Out_0 = _NoiseScale;
            float _SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2;
            Unity_SimpleNoise_float(_RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4, _Property_914ddfeffef649e0a197e87e6d4e8d23_Out_0, _SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2);
            float _Property_4c2407561bc741da9ac554d5c089d653_Out_0 = _ClipTime;
            float _Property_29a2394af39f435089fa0fea9ec9d1aa_Out_0 = _ClipTime;
            float _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2;
            Unity_Add_float(1, _Property_29a2394af39f435089fa0fea9ec9d1aa_Out_0, _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2);
            float2 _Vector2_3666d2cbdbff465990d5c84b040d175e_Out_0 = float2(0, _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2);
            float _Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3;
            Unity_Remap_float(_Property_4c2407561bc741da9ac554d5c089d653_Out_0, float2 (0, 1), _Vector2_3666d2cbdbff465990d5c84b040d175e_Out_0, _Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3);
            float _Property_69571a462025446792a26e20568505f8_Out_0 = _DelayTime;
            float _Subtract_659417884a4f451bb21103f3b415e655_Out_2;
            Unity_Subtract_float(_Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3, _Property_69571a462025446792a26e20568505f8_Out_0, _Subtract_659417884a4f451bb21103f3b415e655_Out_2);
            float _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2;
            Unity_Step_float(_SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2, _Subtract_659417884a4f451bb21103f3b415e655_Out_2, _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2);
            surface.Alpha = 1;
            surface.AlphaClipThreshold = _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }
        
        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _PixelSize;
        float _Speed;
        float _NoiseScale;
        float _DelayTime;
        float _ClipTime;
        float4 _Texture2D_TexelSize;
        float4 _Albedo_Color;
        CBUFFER_END
        
        // Object and Global properties
        TEXTURE2D(_Texture2D);
        SAMPLER(sampler_Texture2D);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Floor_float4(float4 In, out float4 Out)
        {
            Out = floor(In);
        }
        
        void Unity_Truncate_float(float In, out float Out)
        {
            Out = trunc(In);
        }
        
        void Unity_Divide_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A / B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_RadialShear_float(float2 UV, float2 Center, float2 Strength, float2 Offset, out float2 Out)
        {
            float2 delta = UV - Center;
            float delta2 = dot(delta.xy, delta.xy);
            float2 delta_offset = delta2 * Strength;
            Out = UV + float2(delta.y, -delta.x) * delta_offset + Offset;
        }
        
        
        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            float angle = dot(uv, float2(12.9898, 78.233));
            #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
            #endif
            return frac(sin(angle)*43758.5453);
        }
        
        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }
        
        
        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
        
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);
        
            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;
        
            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            Out = t;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_8644611fff744ae4becb69c5781fbba3_Out_0 = IN.uv0;
            float _Property_f9d2955ecfe144dbbeaf77fe52998288_Out_0 = _PixelSize;
            float _Float_6c180475e60843f3957ea88e596932d0_Out_0 = _Property_f9d2955ecfe144dbbeaf77fe52998288_Out_0;
            float4 _Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2;
            Unity_Multiply_float4_float4(_UV_8644611fff744ae4becb69c5781fbba3_Out_0, (_Float_6c180475e60843f3957ea88e596932d0_Out_0.xxxx), _Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2);
            float4 _Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1;
            Unity_Floor_float4(_Multiply_df197a35f68e4ed081b06f1403f8e28c_Out_2, _Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1);
            float _Truncate_f6835003e66c47669c2cb177aba706fa_Out_1;
            Unity_Truncate_float(_Float_6c180475e60843f3957ea88e596932d0_Out_0, _Truncate_f6835003e66c47669c2cb177aba706fa_Out_1);
            float4 _Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2;
            Unity_Divide_float4(_Floor_c9a463c2f62d4895bc12a0ac17498b30_Out_1, (_Truncate_f6835003e66c47669c2cb177aba706fa_Out_1.xxxx), _Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2);
            float _Divide_fd2fa06b391f45b391c0f12db273137f_Out_2;
            Unity_Divide_float(0.45, _Float_6c180475e60843f3957ea88e596932d0_Out_0, _Divide_fd2fa06b391f45b391c0f12db273137f_Out_2);
            float2 _TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3;
            Unity_TilingAndOffset_float((_Divide_6b1d7fa5e4214393a44195680a8b5570_Out_2.xy), float2 (1, 1), (_Divide_fd2fa06b391f45b391c0f12db273137f_Out_2.xx), _TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3);
            float _Property_a3a75f49f4024f68a306a2f1cd130404_Out_0 = _Speed;
            float _Multiply_49ab0549de734441baa0badd6d8f6424_Out_2;
            Unity_Multiply_float_float(_Property_a3a75f49f4024f68a306a2f1cd130404_Out_0, IN.TimeParameters.x, _Multiply_49ab0549de734441baa0badd6d8f6424_Out_2);
            float2 _RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4;
            Unity_RadialShear_float(_TilingAndOffset_bf032ffda93d4343b2bec78ebdd12e99_Out_3, float2 (0.5, 0.5), float2 (3.15, 10), (_Multiply_49ab0549de734441baa0badd6d8f6424_Out_2.xx), _RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4);
            float _Property_914ddfeffef649e0a197e87e6d4e8d23_Out_0 = _NoiseScale;
            float _SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2;
            Unity_SimpleNoise_float(_RadialShear_0fd01ffd93014d52b996a67996c28474_Out_4, _Property_914ddfeffef649e0a197e87e6d4e8d23_Out_0, _SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2);
            float _Property_4c2407561bc741da9ac554d5c089d653_Out_0 = _ClipTime;
            float _Property_29a2394af39f435089fa0fea9ec9d1aa_Out_0 = _ClipTime;
            float _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2;
            Unity_Add_float(1, _Property_29a2394af39f435089fa0fea9ec9d1aa_Out_0, _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2);
            float2 _Vector2_3666d2cbdbff465990d5c84b040d175e_Out_0 = float2(0, _Add_9d9e1334ed6a4126ad82056be823e93e_Out_2);
            float _Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3;
            Unity_Remap_float(_Property_4c2407561bc741da9ac554d5c089d653_Out_0, float2 (0, 1), _Vector2_3666d2cbdbff465990d5c84b040d175e_Out_0, _Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3);
            float _Property_69571a462025446792a26e20568505f8_Out_0 = _DelayTime;
            float _Subtract_659417884a4f451bb21103f3b415e655_Out_2;
            Unity_Subtract_float(_Remap_8fa2380a8d924408b03339e0b979b7b7_Out_3, _Property_69571a462025446792a26e20568505f8_Out_0, _Subtract_659417884a4f451bb21103f3b415e655_Out_2);
            float _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2;
            Unity_Step_float(_SimpleNoise_4a1933afc73a4cfeae7b2a6a1d00e3be_Out_2, _Subtract_659417884a4f451bb21103f3b415e655_Out_2, _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2);
            surface.BaseColor = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
            surface.Alpha = 1;
            surface.AlphaClipThreshold = _Step_f7e1a29a770e48b4b863826a5145e6e4_Out_2;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    FallBack "Hidden/Shader Graph/FallbackError"
}