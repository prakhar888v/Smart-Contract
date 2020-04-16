
contract TemperatureControlledTransportation
{
    //Set of States
    enum StateType { Created, InTransit, Completed, OutOfCompliance}

    //List of properties
    StateType public  State;
    address public  Owner;
    address public  Manufacturer;
    address public  Counterparty;
    address public  PreviousCounterparty;
    address public  Device;
    int public  MinTemperature;
    int public  MaxTemperature;
    SensorType public  SensorType;
    int public  SensorReading;
    bool public  ComplianceStatus;
    string public  ComplianceDetail;
    int public  LastSensorUpdateTimestamp;

    constructor(address device, int minTemperature, int maxTemperature) public
    {
        ComplianceStatus = true;
        SensorReading = "N/A";
        Manufacturer = msg.sender;
        Owner = 'Acme';
        Counterparty = Manufacturer;
        Device = device;
        MinTemperature = minTemperature;
        MaxTemperature = maxTemperature;
        State = StateType.Created;
        ComplianceDetail = "N/A";
    }

    function CheckTemperature(int temperature, int timestamp) public
    {
        if ( State == StateType.Completed )
        {
            revert('Shipment delivered. No need to check for temperature!');
        }

        if ( State == StateType.OutOfCompliance )
        {
            revert('Potential quality issue');
        }

        if (Device != msg.sender)
        {
            revert('Only device can call this function of the contract');
        }

        LastSensorUpdateTimestamp = timestamp;

        if (temperature > MaxTemperature || temperature < MinTemperature)
        {
            SensorReading = temperature;
            ComplianceDetail = "Temperature value out of range.";
            ComplianceStatus = false;
        }

        if (ComplianceStatus == false)
        {
            State = StateType.OutOfCompliance;
        }
    }

    function TransferResponsibility(address newCounterparty) public
    {

        if ( State == StateType.Completed )
        {
            revert('Shipment already completed');
        }

        if ( State == StateType.OutOfCompliance )
        {
            revert('Potential quality issue');
        }

        if ( Manufacturer != msg.sender && Counterparty != msg.sender )
        {
            revert('Only the manufacturer or a counterparty can call this function of the contract');
        }

        if ( newCounterparty == Device )
        {
            revert('Cannot transfer responsibility to the device');
        }

        if (State == StateType.Created)
        {
            State = StateType.InTransit;
        }

        PreviousCounterparty = Counterparty;
        Counterparty = newCounterparty;
    }

    function Complete() public
    {

        if ( State == StateType.Completed )
        {
            revert('Shipment already completed');
        }

        if ( State == StateType.OutOfCompliance )
        {
            revert('Potential quality issue');
        }

        if (Owner != msg.sender)
        {
            revert('Only the owner can call this function of the contract');
        }

        State = StateType.Completed;
        PreviousCounterparty = Counterparty;
        Counterparty = 'Acme plant address';
    }
}
