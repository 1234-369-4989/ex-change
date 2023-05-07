namespace ExChangeParts
{
    // send this struct to the ExchangeSystem from the ExChangeMovementPart
    public struct MovementVariables
    { 
       public bool CanJump;
       public bool CanFloat;
       public float? MoveSpeed;
       public float? SprintSpeed;
       public float? JumpHeight;
       
       //tostring
       
         public override string ToString()
         {
              return $"CanJump: {CanJump}, CanFloat: {CanFloat}, MoveSpeed: {MoveSpeed}, SprintSpeed: {SprintSpeed}, JumpHeight: {JumpHeight}";
         }
    }
    
}