Shader "DitherPixel_UI"
{
    Properties
    {
        [NoScaleOffset]_Texture2D("Texture2D", 2D) = "white" {}
        _Albedo_Color_A("Albedo Color A", Color) = (0.9268703, 0, 1, 0)
        _Albedo_Color_B("Albedo Color B", Color) = (0.9268703, 0, 1, 0)
        _PixelSize("PixelSize", Float) = 20
        _Speed("Speed", Float) = 0
        _NoiseScale("NoiseScale", Float) = 15
        _DelayTime("DelayTime", Float) = 1
        _ClipTime("_ClipTime", Float) = 0.7
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
            "ShaderGraphTargetId"=""
        }
        Pass
        {
            Name "Sprite Lit"
            Tags
            {
                "LightMode" = "Universal2D"
            }
        
            // Render State
            Cull Off
        Blend SrcAlpha One, One One
        ZTest LEqual
        ZWrite Off
        
            // Debug
            // <None>
        
            // --------------------------------------------------
            // Pass
        
            HLSLPROGRAM
        
            // Pragmas
            #pragma target 2.0
        #pragma exclude_renderers d3d11_9x
        #pragma vertex vert
        #pragma fragment frag
        
            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>
        
            // Keywords
            #pragma multi_compile _ USE_SHAPE_LIGHT_TYPE_0
        #pragma multi_compile _ USE_SHAPE_LIGHT_TYPE_1
        #pragma multi_compile _ USE_SHAPE_LIGHT_TYPE_2
        #pragma multi_compile _ USE_SHAPE_LIGHT_TYPE_3
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
            // GraphKeywords: <None>
        
            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _BLENDMODE_ADD 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_COLOR
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_COLOR
            #define VARYINGS_NEED_SCREENPOSITION
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SPRITELIT
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
            // Includes
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreInclude' */
        
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Shaders/2D/Include/LightingUtility.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
            // --------------------------------------------------
            // Structs and Packing
        
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
            struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float4 texCoord0;
             float4 color;
             float4 screenPosition;
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
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
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
            output.interp1.xyzw =  input.texCoord0;
            output.interp2.xyzw =  input.color;
            output.interp3.xyzw =  input.screenPosition;
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
            output.texCoord0 = input.interp1.xyzw;
            output.color = input.interp2.xyzw;
            output.screenPosition = input.interp3.xyzw;
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
        float4 _Texture2D_TexelSize;
        float4 _Albedo_Color_B;
        float4 _Albedo_Color_A;
        float _PixelSize;
        float _Speed;
        float _NoiseScale;
        float _DelayTime;
        float _ClipTime;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
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
            
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
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
            float4 SpriteMask;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_d589c9d5e0b3457b8ec060ac248cb9a8_Out_0 = UnityBuildTexture2DStructNoScale(_Texture2D);
            float4 _SampleTexture2D_af9d15b8fe374040810b856b5d47934e_RGBA_0 = SAMPLE_TEXTURE2D(_Property_d589c9d5e0b3457b8ec060ac248cb9a8_Out_0.tex, _Property_d589c9d5e0b3457b8ec060ac248cb9a8_Out_0.samplerstate, _Property_d589c9d5e0b3457b8ec060ac248cb9a8_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_af9d15b8fe374040810b856b5d47934e_R_4 = _SampleTexture2D_af9d15b8fe374040810b856b5d47934e_RGBA_0.r;
            float _SampleTexture2D_af9d15b8fe374040810b856b5d47934e_G_5 = _SampleTexture2D_af9d15b8fe374040810b856b5d47934e_RGBA_0.g;
            float _SampleTexture2D_af9d15b8fe374040810b856b5d47934e_B_6 = _SampleTexture2D_af9d15b8fe374040810b856b5d47934e_RGBA_0.b;
            float _SampleTexture2D_af9d15b8fe374040810b856b5d47934e_A_7 = _SampleTexture2D_af9d15b8fe374040810b856b5d47934e_RGBA_0.a;
            float4 _Property_53de2445a506451faf4279536d27c836_Out_0 = _Albedo_Color_A;
            float4 _Property_201cde4155344fc48156a0d7bd22f37d_Out_0 = _Albedo_Color_B;
            float4 _UV_9f0ec9947d514ca8afbd64ed5f0648c7_Out_0 = IN.uv0;
            float _Split_f92ac7be22bc45128825b2ff2c26b5d5_R_1 = _UV_9f0ec9947d514ca8afbd64ed5f0648c7_Out_0[0];
            float _Split_f92ac7be22bc45128825b2ff2c26b5d5_G_2 = _UV_9f0ec9947d514ca8afbd64ed5f0648c7_Out_0[1];
            float _Split_f92ac7be22bc45128825b2ff2c26b5d5_B_3 = _UV_9f0ec9947d514ca8afbd64ed5f0648c7_Out_0[2];
            float _Split_f92ac7be22bc45128825b2ff2c26b5d5_A_4 = _UV_9f0ec9947d514ca8afbd64ed5f0648c7_Out_0[3];
            float4 _Lerp_a51d862b9fe44cf3948a8ff87b3e2303_Out_3;
            Unity_Lerp_float4(_Property_53de2445a506451faf4279536d27c836_Out_0, _Property_201cde4155344fc48156a0d7bd22f37d_Out_0, (_Split_f92ac7be22bc45128825b2ff2c26b5d5_G_2.xxxx), _Lerp_a51d862b9fe44cf3948a8ff87b3e2303_Out_3);
            float4 _Multiply_cf8fb225f3a1484b9426de9ac24be2f8_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_af9d15b8fe374040810b856b5d47934e_RGBA_0, _Lerp_a51d862b9fe44cf3948a8ff87b3e2303_Out_3, _Multiply_cf8fb225f3a1484b9426de9ac24be2f8_Out_2);
            float4 _UV_0a766966414b461381592cf08bd045cd_Out_0 = IN.uv0;
            float _Property_9219b8c81eb449dab99b16a1b65600bd_Out_0 = _PixelSize;
            float _Float_d43f0e968f384c68ab63b4358b8b8ea2_Out_0 = _Property_9219b8c81eb449dab99b16a1b65600bd_Out_0;
            float _Float_e21b95ab1659458f9f8f6e2f7f72eeb0_Out_0 = _Float_d43f0e968f384c68ab63b4358b8b8ea2_Out_0;
            float4 _Multiply_765038f6d69640c29d0e31da82e4da24_Out_2;
            Unity_Multiply_float4_float4(_UV_0a766966414b461381592cf08bd045cd_Out_0, (_Float_e21b95ab1659458f9f8f6e2f7f72eeb0_Out_0.xxxx), _Multiply_765038f6d69640c29d0e31da82e4da24_Out_2);
            float4 _Floor_34e5cc2fc2574fc5ae1a930cad56610d_Out_1;
            Unity_Floor_float4(_Multiply_765038f6d69640c29d0e31da82e4da24_Out_2, _Floor_34e5cc2fc2574fc5ae1a930cad56610d_Out_1);
            float _Truncate_bd2294d1e5af4b91865f251a5a3ea4cb_Out_1;
            Unity_Truncate_float(_Float_e21b95ab1659458f9f8f6e2f7f72eeb0_Out_0, _Truncate_bd2294d1e5af4b91865f251a5a3ea4cb_Out_1);
            float4 _Divide_00ac584bbf0c499f81a52d3d1fe3ef98_Out_2;
            Unity_Divide_float4(_Floor_34e5cc2fc2574fc5ae1a930cad56610d_Out_1, (_Truncate_bd2294d1e5af4b91865f251a5a3ea4cb_Out_1.xxxx), _Divide_00ac584bbf0c499f81a52d3d1fe3ef98_Out_2);
            float _Divide_943628b9f8094e398423679a84aba3f1_Out_2;
            Unity_Divide_float(0.45, _Float_e21b95ab1659458f9f8f6e2f7f72eeb0_Out_0, _Divide_943628b9f8094e398423679a84aba3f1_Out_2);
            float2 _TilingAndOffset_de824376759041f8871010230a84b964_Out_3;
            Unity_TilingAndOffset_float((_Divide_00ac584bbf0c499f81a52d3d1fe3ef98_Out_2.xy), float2 (1, 1), (_Divide_943628b9f8094e398423679a84aba3f1_Out_2.xx), _TilingAndOffset_de824376759041f8871010230a84b964_Out_3);
            float _Property_8effe2daf89c474dbc5e02f41d5936cf_Out_0 = _Speed;
            float _Multiply_98d9993f2eca4af086ea54340c030cc7_Out_2;
            Unity_Multiply_float_float(_Property_8effe2daf89c474dbc5e02f41d5936cf_Out_0, IN.TimeParameters.x, _Multiply_98d9993f2eca4af086ea54340c030cc7_Out_2);
            float2 _RadialShear_28d449915df0482e9d83efdad1c40a86_Out_4;
            Unity_RadialShear_float(_TilingAndOffset_de824376759041f8871010230a84b964_Out_3, float2 (0.5, 0.5), float2 (3.15, 10), (_Multiply_98d9993f2eca4af086ea54340c030cc7_Out_2.xx), _RadialShear_28d449915df0482e9d83efdad1c40a86_Out_4);
            float _Property_bceae0f56c474361b62aae4a6e521567_Out_0 = _NoiseScale;
            float _SimpleNoise_8b2b98814e4c44c597b66ca4631fc14e_Out_2;
            Unity_SimpleNoise_float(_RadialShear_28d449915df0482e9d83efdad1c40a86_Out_4, _Property_bceae0f56c474361b62aae4a6e521567_Out_0, _SimpleNoise_8b2b98814e4c44c597b66ca4631fc14e_Out_2);
            float _Property_8012abdbe5294411a8cd638e4c1b3e75_Out_0 = _ClipTime;
            float _Property_b189e95381374f23a5efd09d06145c99_Out_0 = _ClipTime;
            float _Add_3f556561c4c54dd9a33303dc326ecc9c_Out_2;
            Unity_Add_float(1, _Property_b189e95381374f23a5efd09d06145c99_Out_0, _Add_3f556561c4c54dd9a33303dc326ecc9c_Out_2);
            float2 _Vector2_7b2fff7cd5c34f7c87e4839e695de6d2_Out_0 = float2(0, _Add_3f556561c4c54dd9a33303dc326ecc9c_Out_2);
            float _Remap_b8bb59886c474a488207184c29ea6aa8_Out_3;
            Unity_Remap_float(_Property_8012abdbe5294411a8cd638e4c1b3e75_Out_0, float2 (0, 1), _Vector2_7b2fff7cd5c34f7c87e4839e695de6d2_Out_0, _Remap_b8bb59886c474a488207184c29ea6aa8_Out_3);
            float _Property_541f3ece6bce48b7a2212bb609a3a11a_Out_0 = _DelayTime;
            float _Subtract_57d151655699482e846bc887bd4570a0_Out_2;
            Unity_Subtract_float(_Remap_b8bb59886c474a488207184c29ea6aa8_Out_3, _Property_541f3ece6bce48b7a2212bb609a3a11a_Out_0, _Subtract_57d151655699482e846bc887bd4570a0_Out_2);
            float _Step_3cd20230984341cca23bf4efbc0e9475_Out_2;
            Unity_Step_float(_SimpleNoise_8b2b98814e4c44c597b66ca4631fc14e_Out_2, _Subtract_57d151655699482e846bc887bd4570a0_Out_2, _Step_3cd20230984341cca23bf4efbc0e9475_Out_2);
            surface.BaseColor = (_Multiply_cf8fb225f3a1484b9426de9ac24be2f8_Out_2.xyz);
            surface.Alpha = _Step_3cd20230984341cca23bf4efbc0e9475_Out_2;
            surface.SpriteMask = IsGammaSpace() ? float4(1, 1, 1, 1) : float4 (SRGBToLinear(float3(1, 1, 1)), 1);
            return surface;
        }
        
            // --------------------------------------------------
            // Build Graph Inputs
        
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
        
            
        
        
        
        
        
            output.uv0 =                                        input.texCoord0;
            output.TimeParameters =                             _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN                output.FaceSign =                                   IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
            return output;
        }
        
            // --------------------------------------------------
            // Main
        
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/2D/ShaderGraph/Includes/SpriteLitPass.hlsl"
        
            ENDHLSL
        }
        Pass
        {
            Name "Sprite Normal"
            Tags
            {
                "LightMode" = "NormalsRendering"
            }
        
            // Render State
            Cull Off
        Blend SrcAlpha One, One One
        ZTest LEqual
        ZWrite Off
        
            // Debug
            // <None>
        
            // --------------------------------------------------
            // Pass
        
            HLSLPROGRAM
        
            // Pragmas
            #pragma target 2.0
        #pragma exclude_renderers d3d11_9x
        #pragma vertex vert
        #pragma fragment frag
        
            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>
        
            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>
        
            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _BLENDMODE_ADD 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SPRITENORMAL
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
            // Includes
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreInclude' */
        
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Shaders/2D/Include/NormalsRenderingShared.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
            // --------------------------------------------------
            // Structs and Packing
        
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
        float4 _Texture2D_TexelSize;
        float4 _Albedo_Color_B;
        float4 _Albedo_Color_A;
        float _PixelSize;
        float _Speed;
        float _NoiseScale;
        float _DelayTime;
        float _ClipTime;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
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
            
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
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
            float3 NormalTS;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_d589c9d5e0b3457b8ec060ac248cb9a8_Out_0 = UnityBuildTexture2DStructNoScale(_Texture2D);
            float4 _SampleTexture2D_af9d15b8fe374040810b856b5d47934e_RGBA_0 = SAMPLE_TEXTURE2D(_Property_d589c9d5e0b3457b8ec060ac248cb9a8_Out_0.tex, _Property_d589c9d5e0b3457b8ec060ac248cb9a8_Out_0.samplerstate, _Property_d589c9d5e0b3457b8ec060ac248cb9a8_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_af9d15b8fe374040810b856b5d47934e_R_4 = _SampleTexture2D_af9d15b8fe374040810b856b5d47934e_RGBA_0.r;
            float _SampleTexture2D_af9d15b8fe374040810b856b5d47934e_G_5 = _SampleTexture2D_af9d15b8fe374040810b856b5d47934e_RGBA_0.g;
            float _SampleTexture2D_af9d15b8fe374040810b856b5d47934e_B_6 = _SampleTexture2D_af9d15b8fe374040810b856b5d47934e_RGBA_0.b;
            float _SampleTexture2D_af9d15b8fe374040810b856b5d47934e_A_7 = _SampleTexture2D_af9d15b8fe374040810b856b5d47934e_RGBA_0.a;
            float4 _Property_53de2445a506451faf4279536d27c836_Out_0 = _Albedo_Color_A;
            float4 _Property_201cde4155344fc48156a0d7bd22f37d_Out_0 = _Albedo_Color_B;
            float4 _UV_9f0ec9947d514ca8afbd64ed5f0648c7_Out_0 = IN.uv0;
            float _Split_f92ac7be22bc45128825b2ff2c26b5d5_R_1 = _UV_9f0ec9947d514ca8afbd64ed5f0648c7_Out_0[0];
            float _Split_f92ac7be22bc45128825b2ff2c26b5d5_G_2 = _UV_9f0ec9947d514ca8afbd64ed5f0648c7_Out_0[1];
            float _Split_f92ac7be22bc45128825b2ff2c26b5d5_B_3 = _UV_9f0ec9947d514ca8afbd64ed5f0648c7_Out_0[2];
            float _Split_f92ac7be22bc45128825b2ff2c26b5d5_A_4 = _UV_9f0ec9947d514ca8afbd64ed5f0648c7_Out_0[3];
            float4 _Lerp_a51d862b9fe44cf3948a8ff87b3e2303_Out_3;
            Unity_Lerp_float4(_Property_53de2445a506451faf4279536d27c836_Out_0, _Property_201cde4155344fc48156a0d7bd22f37d_Out_0, (_Split_f92ac7be22bc45128825b2ff2c26b5d5_G_2.xxxx), _Lerp_a51d862b9fe44cf3948a8ff87b3e2303_Out_3);
            float4 _Multiply_cf8fb225f3a1484b9426de9ac24be2f8_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_af9d15b8fe374040810b856b5d47934e_RGBA_0, _Lerp_a51d862b9fe44cf3948a8ff87b3e2303_Out_3, _Multiply_cf8fb225f3a1484b9426de9ac24be2f8_Out_2);
            float4 _UV_0a766966414b461381592cf08bd045cd_Out_0 = IN.uv0;
            float _Property_9219b8c81eb449dab99b16a1b65600bd_Out_0 = _PixelSize;
            float _Float_d43f0e968f384c68ab63b4358b8b8ea2_Out_0 = _Property_9219b8c81eb449dab99b16a1b65600bd_Out_0;
            float _Float_e21b95ab1659458f9f8f6e2f7f72eeb0_Out_0 = _Float_d43f0e968f384c68ab63b4358b8b8ea2_Out_0;
            float4 _Multiply_765038f6d69640c29d0e31da82e4da24_Out_2;
            Unity_Multiply_float4_float4(_UV_0a766966414b461381592cf08bd045cd_Out_0, (_Float_e21b95ab1659458f9f8f6e2f7f72eeb0_Out_0.xxxx), _Multiply_765038f6d69640c29d0e31da82e4da24_Out_2);
            float4 _Floor_34e5cc2fc2574fc5ae1a930cad56610d_Out_1;
            Unity_Floor_float4(_Multiply_765038f6d69640c29d0e31da82e4da24_Out_2, _Floor_34e5cc2fc2574fc5ae1a930cad56610d_Out_1);
            float _Truncate_bd2294d1e5af4b91865f251a5a3ea4cb_Out_1;
            Unity_Truncate_float(_Float_e21b95ab1659458f9f8f6e2f7f72eeb0_Out_0, _Truncate_bd2294d1e5af4b91865f251a5a3ea4cb_Out_1);
            float4 _Divide_00ac584bbf0c499f81a52d3d1fe3ef98_Out_2;
            Unity_Divide_float4(_Floor_34e5cc2fc2574fc5ae1a930cad56610d_Out_1, (_Truncate_bd2294d1e5af4b91865f251a5a3ea4cb_Out_1.xxxx), _Divide_00ac584bbf0c499f81a52d3d1fe3ef98_Out_2);
            float _Divide_943628b9f8094e398423679a84aba3f1_Out_2;
            Unity_Divide_float(0.45, _Float_e21b95ab1659458f9f8f6e2f7f72eeb0_Out_0, _Divide_943628b9f8094e398423679a84aba3f1_Out_2);
            float2 _TilingAndOffset_de824376759041f8871010230a84b964_Out_3;
            Unity_TilingAndOffset_float((_Divide_00ac584bbf0c499f81a52d3d1fe3ef98_Out_2.xy), float2 (1, 1), (_Divide_943628b9f8094e398423679a84aba3f1_Out_2.xx), _TilingAndOffset_de824376759041f8871010230a84b964_Out_3);
            float _Property_8effe2daf89c474dbc5e02f41d5936cf_Out_0 = _Speed;
            float _Multiply_98d9993f2eca4af086ea54340c030cc7_Out_2;
            Unity_Multiply_float_float(_Property_8effe2daf89c474dbc5e02f41d5936cf_Out_0, IN.TimeParameters.x, _Multiply_98d9993f2eca4af086ea54340c030cc7_Out_2);
            float2 _RadialShear_28d449915df0482e9d83efdad1c40a86_Out_4;
            Unity_RadialShear_float(_TilingAndOffset_de824376759041f8871010230a84b964_Out_3, float2 (0.5, 0.5), float2 (3.15, 10), (_Multiply_98d9993f2eca4af086ea54340c030cc7_Out_2.xx), _RadialShear_28d449915df0482e9d83efdad1c40a86_Out_4);
            float _Property_bceae0f56c474361b62aae4a6e521567_Out_0 = _NoiseScale;
            float _SimpleNoise_8b2b98814e4c44c597b66ca4631fc14e_Out_2;
            Unity_SimpleNoise_float(_RadialShear_28d449915df0482e9d83efdad1c40a86_Out_4, _Property_bceae0f56c474361b62aae4a6e521567_Out_0, _SimpleNoise_8b2b98814e4c44c597b66ca4631fc14e_Out_2);
            float _Property_8012abdbe5294411a8cd638e4c1b3e75_Out_0 = _ClipTime;
            float _Property_b189e95381374f23a5efd09d06145c99_Out_0 = _ClipTime;
            float _Add_3f556561c4c54dd9a33303dc326ecc9c_Out_2;
            Unity_Add_float(1, _Property_b189e95381374f23a5efd09d06145c99_Out_0, _Add_3f556561c4c54dd9a33303dc326ecc9c_Out_2);
            float2 _Vector2_7b2fff7cd5c34f7c87e4839e695de6d2_Out_0 = float2(0, _Add_3f556561c4c54dd9a33303dc326ecc9c_Out_2);
            float _Remap_b8bb59886c474a488207184c29ea6aa8_Out_3;
            Unity_Remap_float(_Property_8012abdbe5294411a8cd638e4c1b3e75_Out_0, float2 (0, 1), _Vector2_7b2fff7cd5c34f7c87e4839e695de6d2_Out_0, _Remap_b8bb59886c474a488207184c29ea6aa8_Out_3);
            float _Property_541f3ece6bce48b7a2212bb609a3a11a_Out_0 = _DelayTime;
            float _Subtract_57d151655699482e846bc887bd4570a0_Out_2;
            Unity_Subtract_float(_Remap_b8bb59886c474a488207184c29ea6aa8_Out_3, _Property_541f3ece6bce48b7a2212bb609a3a11a_Out_0, _Subtract_57d151655699482e846bc887bd4570a0_Out_2);
            float _Step_3cd20230984341cca23bf4efbc0e9475_Out_2;
            Unity_Step_float(_SimpleNoise_8b2b98814e4c44c597b66ca4631fc14e_Out_2, _Subtract_57d151655699482e846bc887bd4570a0_Out_2, _Step_3cd20230984341cca23bf4efbc0e9475_Out_2);
            surface.BaseColor = (_Multiply_cf8fb225f3a1484b9426de9ac24be2f8_Out_2.xyz);
            surface.Alpha = _Step_3cd20230984341cca23bf4efbc0e9475_Out_2;
            surface.NormalTS = IN.TangentSpaceNormal;
            return surface;
        }
        
            // --------------------------------------------------
            // Build Graph Inputs
        
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
        
            
        
        
        
            output.TangentSpaceNormal =                         float3(0.0f, 0.0f, 1.0f);
        
        
            output.uv0 =                                        input.texCoord0;
            output.TimeParameters =                             _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN                output.FaceSign =                                   IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
            return output;
        }
        
            // --------------------------------------------------
            // Main
        
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/2D/ShaderGraph/Includes/SpriteNormalPass.hlsl"
        
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
        #pragma exclude_renderers d3d11_9x
        #pragma vertex vert
        #pragma fragment frag
        
            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>
        
            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>
        
            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _BLENDMODE_ADD 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
            // Includes
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreInclude' */
        
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
            // --------------------------------------------------
            // Structs and Packing
        
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
        float4 _Texture2D_TexelSize;
        float4 _Albedo_Color_B;
        float4 _Albedo_Color_A;
        float _PixelSize;
        float _Speed;
        float _NoiseScale;
        float _DelayTime;
        float _ClipTime;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
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
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_0a766966414b461381592cf08bd045cd_Out_0 = IN.uv0;
            float _Property_9219b8c81eb449dab99b16a1b65600bd_Out_0 = _PixelSize;
            float _Float_d43f0e968f384c68ab63b4358b8b8ea2_Out_0 = _Property_9219b8c81eb449dab99b16a1b65600bd_Out_0;
            float _Float_e21b95ab1659458f9f8f6e2f7f72eeb0_Out_0 = _Float_d43f0e968f384c68ab63b4358b8b8ea2_Out_0;
            float4 _Multiply_765038f6d69640c29d0e31da82e4da24_Out_2;
            Unity_Multiply_float4_float4(_UV_0a766966414b461381592cf08bd045cd_Out_0, (_Float_e21b95ab1659458f9f8f6e2f7f72eeb0_Out_0.xxxx), _Multiply_765038f6d69640c29d0e31da82e4da24_Out_2);
            float4 _Floor_34e5cc2fc2574fc5ae1a930cad56610d_Out_1;
            Unity_Floor_float4(_Multiply_765038f6d69640c29d0e31da82e4da24_Out_2, _Floor_34e5cc2fc2574fc5ae1a930cad56610d_Out_1);
            float _Truncate_bd2294d1e5af4b91865f251a5a3ea4cb_Out_1;
            Unity_Truncate_float(_Float_e21b95ab1659458f9f8f6e2f7f72eeb0_Out_0, _Truncate_bd2294d1e5af4b91865f251a5a3ea4cb_Out_1);
            float4 _Divide_00ac584bbf0c499f81a52d3d1fe3ef98_Out_2;
            Unity_Divide_float4(_Floor_34e5cc2fc2574fc5ae1a930cad56610d_Out_1, (_Truncate_bd2294d1e5af4b91865f251a5a3ea4cb_Out_1.xxxx), _Divide_00ac584bbf0c499f81a52d3d1fe3ef98_Out_2);
            float _Divide_943628b9f8094e398423679a84aba3f1_Out_2;
            Unity_Divide_float(0.45, _Float_e21b95ab1659458f9f8f6e2f7f72eeb0_Out_0, _Divide_943628b9f8094e398423679a84aba3f1_Out_2);
            float2 _TilingAndOffset_de824376759041f8871010230a84b964_Out_3;
            Unity_TilingAndOffset_float((_Divide_00ac584bbf0c499f81a52d3d1fe3ef98_Out_2.xy), float2 (1, 1), (_Divide_943628b9f8094e398423679a84aba3f1_Out_2.xx), _TilingAndOffset_de824376759041f8871010230a84b964_Out_3);
            float _Property_8effe2daf89c474dbc5e02f41d5936cf_Out_0 = _Speed;
            float _Multiply_98d9993f2eca4af086ea54340c030cc7_Out_2;
            Unity_Multiply_float_float(_Property_8effe2daf89c474dbc5e02f41d5936cf_Out_0, IN.TimeParameters.x, _Multiply_98d9993f2eca4af086ea54340c030cc7_Out_2);
            float2 _RadialShear_28d449915df0482e9d83efdad1c40a86_Out_4;
            Unity_RadialShear_float(_TilingAndOffset_de824376759041f8871010230a84b964_Out_3, float2 (0.5, 0.5), float2 (3.15, 10), (_Multiply_98d9993f2eca4af086ea54340c030cc7_Out_2.xx), _RadialShear_28d449915df0482e9d83efdad1c40a86_Out_4);
            float _Property_bceae0f56c474361b62aae4a6e521567_Out_0 = _NoiseScale;
            float _SimpleNoise_8b2b98814e4c44c597b66ca4631fc14e_Out_2;
            Unity_SimpleNoise_float(_RadialShear_28d449915df0482e9d83efdad1c40a86_Out_4, _Property_bceae0f56c474361b62aae4a6e521567_Out_0, _SimpleNoise_8b2b98814e4c44c597b66ca4631fc14e_Out_2);
            float _Property_8012abdbe5294411a8cd638e4c1b3e75_Out_0 = _ClipTime;
            float _Property_b189e95381374f23a5efd09d06145c99_Out_0 = _ClipTime;
            float _Add_3f556561c4c54dd9a33303dc326ecc9c_Out_2;
            Unity_Add_float(1, _Property_b189e95381374f23a5efd09d06145c99_Out_0, _Add_3f556561c4c54dd9a33303dc326ecc9c_Out_2);
            float2 _Vector2_7b2fff7cd5c34f7c87e4839e695de6d2_Out_0 = float2(0, _Add_3f556561c4c54dd9a33303dc326ecc9c_Out_2);
            float _Remap_b8bb59886c474a488207184c29ea6aa8_Out_3;
            Unity_Remap_float(_Property_8012abdbe5294411a8cd638e4c1b3e75_Out_0, float2 (0, 1), _Vector2_7b2fff7cd5c34f7c87e4839e695de6d2_Out_0, _Remap_b8bb59886c474a488207184c29ea6aa8_Out_3);
            float _Property_541f3ece6bce48b7a2212bb609a3a11a_Out_0 = _DelayTime;
            float _Subtract_57d151655699482e846bc887bd4570a0_Out_2;
            Unity_Subtract_float(_Remap_b8bb59886c474a488207184c29ea6aa8_Out_3, _Property_541f3ece6bce48b7a2212bb609a3a11a_Out_0, _Subtract_57d151655699482e846bc887bd4570a0_Out_2);
            float _Step_3cd20230984341cca23bf4efbc0e9475_Out_2;
            Unity_Step_float(_SimpleNoise_8b2b98814e4c44c597b66ca4631fc14e_Out_2, _Subtract_57d151655699482e846bc887bd4570a0_Out_2, _Step_3cd20230984341cca23bf4efbc0e9475_Out_2);
            surface.Alpha = _Step_3cd20230984341cca23bf4efbc0e9475_Out_2;
            return surface;
        }
        
            // --------------------------------------------------
            // Build Graph Inputs
        
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
        
            
        
        
        
        
        
            output.uv0 =                                        input.texCoord0;
            output.TimeParameters =                             _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN                output.FaceSign =                                   IS_FRONT_VFACE(input.cullFace, true, false);
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
        #pragma exclude_renderers d3d11_9x
        #pragma vertex vert
        #pragma fragment frag
        
            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>
        
            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>
        
            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _BLENDMODE_ADD 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
            // Includes
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreInclude' */
        
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
            // --------------------------------------------------
            // Structs and Packing
        
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
        float4 _Texture2D_TexelSize;
        float4 _Albedo_Color_B;
        float4 _Albedo_Color_A;
        float _PixelSize;
        float _Speed;
        float _NoiseScale;
        float _DelayTime;
        float _ClipTime;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
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
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_0a766966414b461381592cf08bd045cd_Out_0 = IN.uv0;
            float _Property_9219b8c81eb449dab99b16a1b65600bd_Out_0 = _PixelSize;
            float _Float_d43f0e968f384c68ab63b4358b8b8ea2_Out_0 = _Property_9219b8c81eb449dab99b16a1b65600bd_Out_0;
            float _Float_e21b95ab1659458f9f8f6e2f7f72eeb0_Out_0 = _Float_d43f0e968f384c68ab63b4358b8b8ea2_Out_0;
            float4 _Multiply_765038f6d69640c29d0e31da82e4da24_Out_2;
            Unity_Multiply_float4_float4(_UV_0a766966414b461381592cf08bd045cd_Out_0, (_Float_e21b95ab1659458f9f8f6e2f7f72eeb0_Out_0.xxxx), _Multiply_765038f6d69640c29d0e31da82e4da24_Out_2);
            float4 _Floor_34e5cc2fc2574fc5ae1a930cad56610d_Out_1;
            Unity_Floor_float4(_Multiply_765038f6d69640c29d0e31da82e4da24_Out_2, _Floor_34e5cc2fc2574fc5ae1a930cad56610d_Out_1);
            float _Truncate_bd2294d1e5af4b91865f251a5a3ea4cb_Out_1;
            Unity_Truncate_float(_Float_e21b95ab1659458f9f8f6e2f7f72eeb0_Out_0, _Truncate_bd2294d1e5af4b91865f251a5a3ea4cb_Out_1);
            float4 _Divide_00ac584bbf0c499f81a52d3d1fe3ef98_Out_2;
            Unity_Divide_float4(_Floor_34e5cc2fc2574fc5ae1a930cad56610d_Out_1, (_Truncate_bd2294d1e5af4b91865f251a5a3ea4cb_Out_1.xxxx), _Divide_00ac584bbf0c499f81a52d3d1fe3ef98_Out_2);
            float _Divide_943628b9f8094e398423679a84aba3f1_Out_2;
            Unity_Divide_float(0.45, _Float_e21b95ab1659458f9f8f6e2f7f72eeb0_Out_0, _Divide_943628b9f8094e398423679a84aba3f1_Out_2);
            float2 _TilingAndOffset_de824376759041f8871010230a84b964_Out_3;
            Unity_TilingAndOffset_float((_Divide_00ac584bbf0c499f81a52d3d1fe3ef98_Out_2.xy), float2 (1, 1), (_Divide_943628b9f8094e398423679a84aba3f1_Out_2.xx), _TilingAndOffset_de824376759041f8871010230a84b964_Out_3);
            float _Property_8effe2daf89c474dbc5e02f41d5936cf_Out_0 = _Speed;
            float _Multiply_98d9993f2eca4af086ea54340c030cc7_Out_2;
            Unity_Multiply_float_float(_Property_8effe2daf89c474dbc5e02f41d5936cf_Out_0, IN.TimeParameters.x, _Multiply_98d9993f2eca4af086ea54340c030cc7_Out_2);
            float2 _RadialShear_28d449915df0482e9d83efdad1c40a86_Out_4;
            Unity_RadialShear_float(_TilingAndOffset_de824376759041f8871010230a84b964_Out_3, float2 (0.5, 0.5), float2 (3.15, 10), (_Multiply_98d9993f2eca4af086ea54340c030cc7_Out_2.xx), _RadialShear_28d449915df0482e9d83efdad1c40a86_Out_4);
            float _Property_bceae0f56c474361b62aae4a6e521567_Out_0 = _NoiseScale;
            float _SimpleNoise_8b2b98814e4c44c597b66ca4631fc14e_Out_2;
            Unity_SimpleNoise_float(_RadialShear_28d449915df0482e9d83efdad1c40a86_Out_4, _Property_bceae0f56c474361b62aae4a6e521567_Out_0, _SimpleNoise_8b2b98814e4c44c597b66ca4631fc14e_Out_2);
            float _Property_8012abdbe5294411a8cd638e4c1b3e75_Out_0 = _ClipTime;
            float _Property_b189e95381374f23a5efd09d06145c99_Out_0 = _ClipTime;
            float _Add_3f556561c4c54dd9a33303dc326ecc9c_Out_2;
            Unity_Add_float(1, _Property_b189e95381374f23a5efd09d06145c99_Out_0, _Add_3f556561c4c54dd9a33303dc326ecc9c_Out_2);
            float2 _Vector2_7b2fff7cd5c34f7c87e4839e695de6d2_Out_0 = float2(0, _Add_3f556561c4c54dd9a33303dc326ecc9c_Out_2);
            float _Remap_b8bb59886c474a488207184c29ea6aa8_Out_3;
            Unity_Remap_float(_Property_8012abdbe5294411a8cd638e4c1b3e75_Out_0, float2 (0, 1), _Vector2_7b2fff7cd5c34f7c87e4839e695de6d2_Out_0, _Remap_b8bb59886c474a488207184c29ea6aa8_Out_3);
            float _Property_541f3ece6bce48b7a2212bb609a3a11a_Out_0 = _DelayTime;
            float _Subtract_57d151655699482e846bc887bd4570a0_Out_2;
            Unity_Subtract_float(_Remap_b8bb59886c474a488207184c29ea6aa8_Out_3, _Property_541f3ece6bce48b7a2212bb609a3a11a_Out_0, _Subtract_57d151655699482e846bc887bd4570a0_Out_2);
            float _Step_3cd20230984341cca23bf4efbc0e9475_Out_2;
            Unity_Step_float(_SimpleNoise_8b2b98814e4c44c597b66ca4631fc14e_Out_2, _Subtract_57d151655699482e846bc887bd4570a0_Out_2, _Step_3cd20230984341cca23bf4efbc0e9475_Out_2);
            surface.Alpha = _Step_3cd20230984341cca23bf4efbc0e9475_Out_2;
            return surface;
        }
        
            // --------------------------------------------------
            // Build Graph Inputs
        
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
        
            
        
        
        
        
        
            output.uv0 =                                        input.texCoord0;
            output.TimeParameters =                             _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN                output.FaceSign =                                   IS_FRONT_VFACE(input.cullFace, true, false);
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
        
            ENDHLSL
        }
        Pass
        {
            Name "Sprite Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
        
            // Render State
            Cull Off
        Blend SrcAlpha One, One One
        ZTest LEqual
        ZWrite Off
        
            // Debug
            // <None>
        
            // --------------------------------------------------
            // Pass
        
            HLSLPROGRAM
        
            // Pragmas
            #pragma target 2.0
        #pragma exclude_renderers d3d11_9x
        #pragma vertex vert
        #pragma fragment frag
        
            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>
        
            // Keywords
            #pragma multi_compile_fragment _ DEBUG_DISPLAY
            // GraphKeywords: <None>
        
            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _BLENDMODE_ADD 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_COLOR
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_COLOR
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SPRITEFORWARD
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
            // Includes
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreInclude' */
        
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
            // --------------------------------------------------
            // Structs and Packing
        
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
            struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float4 texCoord0;
             float4 color;
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
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyzw =  input.texCoord0;
            output.interp2.xyzw =  input.color;
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
            output.texCoord0 = input.interp1.xyzw;
            output.color = input.interp2.xyzw;
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
        float4 _Texture2D_TexelSize;
        float4 _Albedo_Color_B;
        float4 _Albedo_Color_A;
        float _PixelSize;
        float _Speed;
        float _NoiseScale;
        float _DelayTime;
        float _ClipTime;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
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
            
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
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
            float3 NormalTS;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_d589c9d5e0b3457b8ec060ac248cb9a8_Out_0 = UnityBuildTexture2DStructNoScale(_Texture2D);
            float4 _SampleTexture2D_af9d15b8fe374040810b856b5d47934e_RGBA_0 = SAMPLE_TEXTURE2D(_Property_d589c9d5e0b3457b8ec060ac248cb9a8_Out_0.tex, _Property_d589c9d5e0b3457b8ec060ac248cb9a8_Out_0.samplerstate, _Property_d589c9d5e0b3457b8ec060ac248cb9a8_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_af9d15b8fe374040810b856b5d47934e_R_4 = _SampleTexture2D_af9d15b8fe374040810b856b5d47934e_RGBA_0.r;
            float _SampleTexture2D_af9d15b8fe374040810b856b5d47934e_G_5 = _SampleTexture2D_af9d15b8fe374040810b856b5d47934e_RGBA_0.g;
            float _SampleTexture2D_af9d15b8fe374040810b856b5d47934e_B_6 = _SampleTexture2D_af9d15b8fe374040810b856b5d47934e_RGBA_0.b;
            float _SampleTexture2D_af9d15b8fe374040810b856b5d47934e_A_7 = _SampleTexture2D_af9d15b8fe374040810b856b5d47934e_RGBA_0.a;
            float4 _Property_53de2445a506451faf4279536d27c836_Out_0 = _Albedo_Color_A;
            float4 _Property_201cde4155344fc48156a0d7bd22f37d_Out_0 = _Albedo_Color_B;
            float4 _UV_9f0ec9947d514ca8afbd64ed5f0648c7_Out_0 = IN.uv0;
            float _Split_f92ac7be22bc45128825b2ff2c26b5d5_R_1 = _UV_9f0ec9947d514ca8afbd64ed5f0648c7_Out_0[0];
            float _Split_f92ac7be22bc45128825b2ff2c26b5d5_G_2 = _UV_9f0ec9947d514ca8afbd64ed5f0648c7_Out_0[1];
            float _Split_f92ac7be22bc45128825b2ff2c26b5d5_B_3 = _UV_9f0ec9947d514ca8afbd64ed5f0648c7_Out_0[2];
            float _Split_f92ac7be22bc45128825b2ff2c26b5d5_A_4 = _UV_9f0ec9947d514ca8afbd64ed5f0648c7_Out_0[3];
            float4 _Lerp_a51d862b9fe44cf3948a8ff87b3e2303_Out_3;
            Unity_Lerp_float4(_Property_53de2445a506451faf4279536d27c836_Out_0, _Property_201cde4155344fc48156a0d7bd22f37d_Out_0, (_Split_f92ac7be22bc45128825b2ff2c26b5d5_G_2.xxxx), _Lerp_a51d862b9fe44cf3948a8ff87b3e2303_Out_3);
            float4 _Multiply_cf8fb225f3a1484b9426de9ac24be2f8_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_af9d15b8fe374040810b856b5d47934e_RGBA_0, _Lerp_a51d862b9fe44cf3948a8ff87b3e2303_Out_3, _Multiply_cf8fb225f3a1484b9426de9ac24be2f8_Out_2);
            float4 _UV_0a766966414b461381592cf08bd045cd_Out_0 = IN.uv0;
            float _Property_9219b8c81eb449dab99b16a1b65600bd_Out_0 = _PixelSize;
            float _Float_d43f0e968f384c68ab63b4358b8b8ea2_Out_0 = _Property_9219b8c81eb449dab99b16a1b65600bd_Out_0;
            float _Float_e21b95ab1659458f9f8f6e2f7f72eeb0_Out_0 = _Float_d43f0e968f384c68ab63b4358b8b8ea2_Out_0;
            float4 _Multiply_765038f6d69640c29d0e31da82e4da24_Out_2;
            Unity_Multiply_float4_float4(_UV_0a766966414b461381592cf08bd045cd_Out_0, (_Float_e21b95ab1659458f9f8f6e2f7f72eeb0_Out_0.xxxx), _Multiply_765038f6d69640c29d0e31da82e4da24_Out_2);
            float4 _Floor_34e5cc2fc2574fc5ae1a930cad56610d_Out_1;
            Unity_Floor_float4(_Multiply_765038f6d69640c29d0e31da82e4da24_Out_2, _Floor_34e5cc2fc2574fc5ae1a930cad56610d_Out_1);
            float _Truncate_bd2294d1e5af4b91865f251a5a3ea4cb_Out_1;
            Unity_Truncate_float(_Float_e21b95ab1659458f9f8f6e2f7f72eeb0_Out_0, _Truncate_bd2294d1e5af4b91865f251a5a3ea4cb_Out_1);
            float4 _Divide_00ac584bbf0c499f81a52d3d1fe3ef98_Out_2;
            Unity_Divide_float4(_Floor_34e5cc2fc2574fc5ae1a930cad56610d_Out_1, (_Truncate_bd2294d1e5af4b91865f251a5a3ea4cb_Out_1.xxxx), _Divide_00ac584bbf0c499f81a52d3d1fe3ef98_Out_2);
            float _Divide_943628b9f8094e398423679a84aba3f1_Out_2;
            Unity_Divide_float(0.45, _Float_e21b95ab1659458f9f8f6e2f7f72eeb0_Out_0, _Divide_943628b9f8094e398423679a84aba3f1_Out_2);
            float2 _TilingAndOffset_de824376759041f8871010230a84b964_Out_3;
            Unity_TilingAndOffset_float((_Divide_00ac584bbf0c499f81a52d3d1fe3ef98_Out_2.xy), float2 (1, 1), (_Divide_943628b9f8094e398423679a84aba3f1_Out_2.xx), _TilingAndOffset_de824376759041f8871010230a84b964_Out_3);
            float _Property_8effe2daf89c474dbc5e02f41d5936cf_Out_0 = _Speed;
            float _Multiply_98d9993f2eca4af086ea54340c030cc7_Out_2;
            Unity_Multiply_float_float(_Property_8effe2daf89c474dbc5e02f41d5936cf_Out_0, IN.TimeParameters.x, _Multiply_98d9993f2eca4af086ea54340c030cc7_Out_2);
            float2 _RadialShear_28d449915df0482e9d83efdad1c40a86_Out_4;
            Unity_RadialShear_float(_TilingAndOffset_de824376759041f8871010230a84b964_Out_3, float2 (0.5, 0.5), float2 (3.15, 10), (_Multiply_98d9993f2eca4af086ea54340c030cc7_Out_2.xx), _RadialShear_28d449915df0482e9d83efdad1c40a86_Out_4);
            float _Property_bceae0f56c474361b62aae4a6e521567_Out_0 = _NoiseScale;
            float _SimpleNoise_8b2b98814e4c44c597b66ca4631fc14e_Out_2;
            Unity_SimpleNoise_float(_RadialShear_28d449915df0482e9d83efdad1c40a86_Out_4, _Property_bceae0f56c474361b62aae4a6e521567_Out_0, _SimpleNoise_8b2b98814e4c44c597b66ca4631fc14e_Out_2);
            float _Property_8012abdbe5294411a8cd638e4c1b3e75_Out_0 = _ClipTime;
            float _Property_b189e95381374f23a5efd09d06145c99_Out_0 = _ClipTime;
            float _Add_3f556561c4c54dd9a33303dc326ecc9c_Out_2;
            Unity_Add_float(1, _Property_b189e95381374f23a5efd09d06145c99_Out_0, _Add_3f556561c4c54dd9a33303dc326ecc9c_Out_2);
            float2 _Vector2_7b2fff7cd5c34f7c87e4839e695de6d2_Out_0 = float2(0, _Add_3f556561c4c54dd9a33303dc326ecc9c_Out_2);
            float _Remap_b8bb59886c474a488207184c29ea6aa8_Out_3;
            Unity_Remap_float(_Property_8012abdbe5294411a8cd638e4c1b3e75_Out_0, float2 (0, 1), _Vector2_7b2fff7cd5c34f7c87e4839e695de6d2_Out_0, _Remap_b8bb59886c474a488207184c29ea6aa8_Out_3);
            float _Property_541f3ece6bce48b7a2212bb609a3a11a_Out_0 = _DelayTime;
            float _Subtract_57d151655699482e846bc887bd4570a0_Out_2;
            Unity_Subtract_float(_Remap_b8bb59886c474a488207184c29ea6aa8_Out_3, _Property_541f3ece6bce48b7a2212bb609a3a11a_Out_0, _Subtract_57d151655699482e846bc887bd4570a0_Out_2);
            float _Step_3cd20230984341cca23bf4efbc0e9475_Out_2;
            Unity_Step_float(_SimpleNoise_8b2b98814e4c44c597b66ca4631fc14e_Out_2, _Subtract_57d151655699482e846bc887bd4570a0_Out_2, _Step_3cd20230984341cca23bf4efbc0e9475_Out_2);
            surface.BaseColor = (_Multiply_cf8fb225f3a1484b9426de9ac24be2f8_Out_2.xyz);
            surface.Alpha = _Step_3cd20230984341cca23bf4efbc0e9475_Out_2;
            surface.NormalTS = IN.TangentSpaceNormal;
            return surface;
        }
        
            // --------------------------------------------------
            // Build Graph Inputs
        
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
        
            
        
        
        
            output.TangentSpaceNormal =                         float3(0.0f, 0.0f, 1.0f);
        
        
            output.uv0 =                                        input.texCoord0;
            output.TimeParameters =                             _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN                output.FaceSign =                                   IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
            return output;
        }
        
            // --------------------------------------------------
            // Main
        
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/2D/ShaderGraph/Includes/SpriteForwardPass.hlsl"
        
            ENDHLSL
        }
    }
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    FallBack "Hidden/Shader Graph/FallbackError"
}