namespace ExChangeParts
{
    // painting should change the color of the robot
    public class Painting : ExchangePart
    {
        private void Start()
        {
            Type = PartType.Design;
        }

        protected override void OnEquip()
        {
            // change color
        }

        protected override void OnUnequip()
        {
            
        }
    }
}