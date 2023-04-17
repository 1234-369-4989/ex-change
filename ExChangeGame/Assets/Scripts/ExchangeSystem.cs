using System.Linq;
using DefaultNamespace;
using UnityEngine;

public class ExchangeSystem : MonoBehaviour
{
    [SerializeField] private Transform[] partPlaces;
    private ExchangePart[] _parts;

    [SerializeField] private GameObject forward;
    [SerializeField] private GameObject backward;

    private int _currentPart;
    private int _maxPart;

    private void Start()
    {
        _parts = new ExchangePart[partPlaces.Length];
        forward.SetActive(false);
        backward.SetActive(false);
    }

    public void ActivateForward()
    {
        forward.SetActive(true);
        _maxPart = 2;
    }

    public void ActivateBackward()
    {
        if (_maxPart <= 0) return;
        backward.SetActive(true);
        _maxPart = 4;
    }

    public void ChangeParts(ExchangePart newPart)
    {
        if (_maxPart <= 0) return;
        if(CheckPart(newPart)) return;
        if (_parts[_currentPart] != null)
            Destroy(_parts[_currentPart].gameObject);
        GameObject go = Instantiate(newPart.gameObject, partPlaces[_currentPart], true);
        go.transform.position = partPlaces[_currentPart].position;
        go.transform.rotation = partPlaces[_currentPart].rotation;
        _parts[_currentPart] = go.GetComponent<ExchangePart>();
        _currentPart++;
        if (_currentPart >= _maxPart)
            _currentPart = 0;
    }

    private bool CheckPart(ExchangePart newPart)
    {
        return _parts.Any(part => part != null && part.Equals(newPart));
    }
}