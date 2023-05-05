namespace ExChangeParts
{
    public class Saw : ExchangePart
    {
        protected override void OnEquip()
        {
      
        }

        protected override void OnUnequip()
        {
       
        }
        
        // void FixedUpdate()
        // {
        //     // Bewegung mit dem Character Controller durchführen
        //     controller.Move(new Vector3(0f, -1f, 0f) * Time.fixedDeltaTime);
        //
        //     // Überprüfen, ob das zusätzliche Objekt mit einem anderen Objekt kollidiert
        //     Collider[] colliders = Physics.OverlapBox(additionalObject.transform.position, additionalObject.transform.localScale / 2f, additionalObject.transform.rotation, LayerMask.GetMask("Walls"));
        //     if (colliders.Length > 0)
        //     {
        //         // Wenn das Objekt mit einem anderen Objekt kollidiert, den Character Controller anhalten
        //         controller.Move(new Vector3(0f, 1f, 0f) * Time.fixedDeltaTime);
        //     }
        // }
    }
}
