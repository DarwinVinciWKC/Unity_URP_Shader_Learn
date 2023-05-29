using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class ZoomBlur : VolumeComponent, IPostProcessComponent
{
    [Range(0f, 100f), Tooltip("��ǿЧ��ʹģ��Ч����ǿ")]
    public FloatParameter focusPower = new FloatParameter(0f);
    [Range(0, 10), Tooltip("ֵԽ��Խ�ã����Ǹ��ؽ�����...")]
    public IntParameter focusDetail = new IntParameter(5);
    [Tooltip("ģ�����������Ѿ�����Ļ�����ģ�0��0��")]
    public Vector2Parameter focusScreenPostion = new Vector2Parameter(Vector2.zero);
    [Tooltip("�ο�����ֱ���")]
    public IntParameter referenceResolutionX = new IntParameter(1334);

    public bool IsActive() => focusPower.value > 0f;

    public bool IsTileCompatible() => false;
}