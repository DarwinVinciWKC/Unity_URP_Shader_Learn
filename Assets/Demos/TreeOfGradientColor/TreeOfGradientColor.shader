Shader "Demo/SimpleShadow/Tree of Gradient Color" {
    Properties {
        _MainTex ("MainTex", 2D) = "white" { }
        [Toggle]ReceiveShadow ("Receive Shadow", int) = 1
        _LightDirection ("LightDirection", vector) = (0.3, 0.1, -0.1, 0)
        [Header(Gradient)]
        [Toggle]GradientSwitch ("Gradient Switch", int) = 1
        _GradientTex ("GradientTex", 2D) = "white" { }
        _GradientReferenceLine ("GradientReference Line", float) = 0
        _GradientRange ("Gradient Range", float) = 1.5
        [Header(Diffuse)]
        [Toggle]DiffuseSwitch ("Diffuse Switch", int) = 1
        _FrontLightColor ("Front Light Color", Color) = (1, 1, 1, 1)
        _BackLightColor ("Back Light Color", Color) = (1, 1, 1, 1)
        _DiffuseFrontIntensity ("Diffuse Front Intensity", float) = 0.7
        _DiffuseBackIntensity ("Diffuse Back Intensity", float) = 0.3
        [Header(Specular)]
        [Toggle]SpecularSwitch ("Specular Switch", int) = 1
        _SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)
        _SpecularIntensity ("SpecularIntensity", Range(1, 10)) = 5
        _Gloss ("Gloss", Range(0, 2)) = 0.5
        [Header(Alpha)]
        _Alpah ("Alpha", Range(0, 1)) = 1
        [Toggle]AlphaClip ("Alpah Clipping", int) = 0
        _Cutoff ("Alpha Clip Threshold", Range(0, 1)) = 1
        [Header(Other Settings)]
        [Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend ("SrcBlend   [One  SrcAlpha]", float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)]_DstBlend ("DstBlend   [Zero  OneMinusSrcAlpha]", float) = 0
        [Enum(On, 1, Off, 0)]_ZWrite ("ZWrite        [On  Off]", float) = 1
    }

    SubShader {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "UniversalMaterialType" = "Lit" "IgnoreProjector" = "True" "ShaderModel" = "4.5" }

        Pass {
            Tags { "LightMode" = "UniversalForward" }

            Blend[_SrcBlend][_DstBlend]
            ZWrite[_ZWrite]
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma shader_feature ALPHACLIP_ON
            #pragma shader_feature DIFFUSESWITCH_ON
            #pragma shader_feature SPECULARSWITCH_ON
            #pragma shader_feature GRADIENTSWITCH_ON
            #pragma shader_feature RECEIVESHADOW_ON

            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS //���������Դ
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS //����Դ��Ӱ
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE //����Դ�㼶��Ӱ�Ƿ���
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS //�����Դ��Ӱ
            #pragma multi_compile _ _SHADOWS_SOFT //����Ӱ


            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Varyings {
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;
                float4 shadowCoord : TEXCOORD3;
            };
            
            sampler2D _MainTex;
            sampler2D _GradientTex;
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float _DiffuseFrontIntensity;
            float _Gloss;
            float _SpecularIntensity;
            half4 _FrontLightColor;
            half4 _BackLightColor;
            half4 _SpecularColor;
            float _DiffuseBackIntensity;
            half _Alpah;
            float _Cutoff;
            float4 _LightDirection;
            float _GradientReferenceLine;
            float _GradientRange;
            CBUFFER_END

            Varyings vert(Attributes IN) {

                Varyings OUT;
                
                OUT.vertex = TransformObjectToHClip(IN.vertex.xyz);
                
                OUT.worldNormal = mul(IN.normal, (float3x3)unity_WorldToObject);

                OUT.worldPos = mul(unity_ObjectToWorld, IN.vertex).xyz;

                OUT.uv = IN.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;

                OUT.shadowCoord = TransformWorldToShadowCoord(OUT.worldPos);

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target {

                half4 albedo = tex2D(_MainTex, IN.uv);//Albedo�����˶��ٺ�������������
                /*
                       ������ָ���ǹ��߱��������淴������ı��������������в����Ĺ⡣����ķ����ʲ�ͬ�����Ĺ��߿��ܻ��������졣�ڿɼ����׷�Χ�ڣ�
                ��ͬ��ɫ�ĹⲨ����Ӧ��ͬ����ɫ�����������䵽������ʱ������ķ����ʻ�Ӱ�첻ͬ������ķ���̶ȡ�
                       ���磬���ں�ɫ���壬���ܹ����մ󲿷ֵķǺ�ɫ�����⣬�������ɫ�����⣬������ǿ������Ǻ�ɫ�ġ���Ӧ�أ�������ɫ���壬������
                �󲿷ַ���ɫ�����⣬��������ɫ�����⡣
                       ��ˣ������ʲ����������ض��Ĳ�����Χ�����Ǳ�ʾ��������в������ߵķ�����������ͬ�����Ĺ����ڷ�������п��ܻᱻ�������ա�ɢ
                ����䣬�����γ��������۲쵽����ɫ�����ȡ�
                */
                float3 worldNormal = normalize(IN.worldNormal);
                float3 worldLightDir = normalize(_LightDirection.xyz);
                
                float halfLambert = dot(worldNormal, worldLightDir) * 0.5 + 0.5;
                half3 diffuse = _FrontLightColor.rgb * albedo.rgb * halfLambert * _DiffuseFrontIntensity;
                float oneMinusHalfLambert = 1 - halfLambert;
                diffuse += _BackLightColor.rgb * albedo.rgb * oneMinusHalfLambert * _DiffuseBackIntensity;

                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - IN.worldPos.xyz);
                float3 halfDir = normalize(worldLightDir + viewDir);
                half3 specular = _SpecularColor.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss * 256) * _SpecularIntensity;
                
                half3 color = albedo.rgb;
                #if defined(DIFFUSESWITCH_ON)
                    color = diffuse;
                #endif
                #if defined(SPECULARSWITCH_ON)
                    color += specular;
                #endif
                
                #if defined(RECEIVESHADOW_ON)
                    Light  lightData = GetMainLight(IN.shadowCoord);
                    half shadow = lightData.shadowAttenuation;
                    float Ramp_light = saturate(dot(lightData.direction, IN.worldNormal));
                    color.rgb *= Ramp_light * lightData.color.rgb * shadow + _GlossyEnvironmentColor.rgb;
                #endif

                #if defined(ALPHACLIP_ON)
                    half alphaTest = albedo.a;
                    clip(alphaTest - _Cutoff);
                    _Alpah *= alphaTest;
                #endif

                #if defined(GRADIENTSWITCH_ON)
                    float delta = IN.worldPos.y - _GradientReferenceLine;
                    float ratio = delta / _GradientRange;
                    float2 gradientUV = float2(0, ratio);
                    half4 gradientColor = tex2D(_GradientTex, gradientUV) * 5;
                    color *= gradientColor;
                #endif


                return half4(color, _Alpah);
            }
            ENDHLSL
        }

        Pass {
            Tags { "LightMode" = "ShadowCaster" }
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            
            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
            
            sampler2D _MainTex;
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float _DiffuseFrontIntensity;
            float _Gloss;
            float _SpecularIntensity;
            half4 _FrontLightColor;
            half4 _BackLightColor;
            half4 _SpecularColor;
            float _DiffuseBackIntensity;
            half _Alpah;
            float _Cutoff;
            float4 _LightDirection;
            float _GradientReferenceLine;
            float _GradientRange;
            CBUFFER_END
            
            v2f vert(appdata v) {
                v2f o;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                o.uv = v.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                return o;
            }

            float4 frag(v2f i) : SV_Target {
                float4 color = tex2D(_MainTex, i.uv);
                color.xyz = float3(0.0, 0.0, 0.0);
                clip(color.a - 1);
                return color;
            }
            ENDHLSL
        }
    }
}