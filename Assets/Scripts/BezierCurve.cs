using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class BezierCurve
{
    /// <summary>
    /// 给定n+1个控制点，和t的增量，获得曲线上的点，增量越小，曲线越平滑
    /// </summary>
    /// <param name="controlPoints">控制点</param>
    /// <param name="delta">增量</param>
    /// <returns>曲线上点的集合</returns>
    public static List<Vector3> GetCurvePoints(Vector3[] controlPoints, float delta)
    {
        List<Vector3> curvePoints = new List<Vector3>();
        for (float t = 0; t <= 1; t += delta)
            curvePoints.Add(GetBt(controlPoints, t));
        return curvePoints;
    }
    /// <summary>
    /// 给定n+1个点，这些点为控制点，返回t值时的B(t)
    /// </summary>
    /// <param name="controlPoints">控制点</param>
    /// <param name="t">[0,1]</param>
    /// <returns>B(t)</returns>
    private static Vector3 GetBt(Vector3[] controlPoints, float t)
    {
        int n = controlPoints.Length - 1;
        Vector3 curvePoint = Vector3.zero;
        for (int k = 0; k <= n; k++)
            curvePoint += Factorial(n) / (Factorial(k) * Factorial(n - k)) * Mathf.Pow(t, k) * Mathf.Pow(1 - t, n - k) * controlPoints[k];
        return curvePoint;
    }
    /// <summary>
    /// 计算阶乘
    /// </summary>
    /// <param name="n">整数n</param>
    /// <returns>n！</returns>
    private static int Factorial(int n)
    {
        if (n == 1 || n == 0)
            return 1;
        else
            return n * Factorial(n - 1);
    }
}