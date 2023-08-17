using UnityEngine;

namespace ExChangeParts
{
    // parent class for all movement parts like jump springs and turbines
    public class ExChangeMovementPart : ExchangePart
    {
        
        [Header("Movement Variables")]
        [SerializeField] private bool canJump;
        [SerializeField] private bool canFloat;
        
        [SerializeField] private float moveSpeed = 5f;
        [SerializeField] private float sprintSpeed = 5f;
        [SerializeField] private float jumpHeight = 5f;
        
        [Header("Other Variables")]
        [SerializeField] private bool canTakeFallDamage;
        
        protected override void OnEquip()
        {
            var movementVariables = new MovementVariables
            {
                CanJump = canJump,
                CanFloat = canFloat,
                MoveSpeed = moveSpeed != 0 ? moveSpeed : null,
                SprintSpeed = sprintSpeed != 0 ? sprintSpeed : null,
                JumpHeight = jumpHeight != 0 ? jumpHeight : null
            };
            ExchangeSystem.Instance.SetMovement(movementVariables);
            UIControlls.Instance.setJumpActiveTrue();
            // TODO: handle fall damage
        }

        protected override void OnUnequip()
        {
            var movementVariables = new MovementVariables
            {
                CanJump = false,
                CanFloat = false,
                MoveSpeed = null,
                SprintSpeed = null,
                JumpHeight = null
            };
            UIControlls.Instance.setJumpActiveFalse();
            ExchangeSystem.Instance.SetMovement(movementVariables);
        }
    }
}