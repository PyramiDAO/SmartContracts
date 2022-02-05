interface ISwapReceiver{
    function verifyNewSwap(address _swapCreator, uint _amountUnderlying) external view returns(bool);

    // needs function to claim funds when swap is expired
}