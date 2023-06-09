using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Rendering;
[Serializable]
public class ZoomBlurBehaviour : PlayableBehaviour
{
    [HideInInspector]
    public Volume volume;
    public VolumeProfile profile;
    public int layer;
    public AnimationCurve weightCurve = AnimationCurve.Linear(0, 0, 1, 1);
    public override void OnBehaviourPlay(Playable playable, FrameData info)
    {
        if (profile != null)
            QuickVolume();
    }
    public override void OnBehaviourPause(Playable playable, FrameData info)
    {
        if (volume != null)
            GameObject.DestroyImmediate(volume.gameObject);
    }

    void QuickVolume()
    {
        if (volume == null)
        {
            volume = new GameObject().AddComponent<Volume>();
            volume.gameObject.layer = layer;
            volume.gameObject.hideFlags = HideFlags.DontSave | HideFlags.NotEditable;
            volume.gameObject.name = $"ZoomBlurBehaviourVolume[Profile{profile.name}]";
            volume.weight = 0;
            volume.priority = 1;
            volume.isGlobal = true;
            volume.profile = profile;
        }
    }
    public void ChangeWeight(float time)
    {
        if (volume == null) return;
        volume.weight = weightCurve.Evaluate(time);
    }
}
