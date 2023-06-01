using System;
using UnityEngine;
using UnityEngine.Events;

namespace Dialog
{
    [Serializable]
    public struct Dialog
    {
        public string name;
        [TextArea(3,10)]
        public string[] sentences;
        public UnityEvent onComplete;
    }
}