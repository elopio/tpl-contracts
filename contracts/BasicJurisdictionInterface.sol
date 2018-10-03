pragma solidity ^0.4.24;

interface BasicJurisdictionInterface {
  // NOTE: Basic jurisdictions will not use some of the fields on this interface
  // ZEPPELIN-AUDIT: why isn't there a simplified interface that this one can
  // fully use, and then a more complex one that builds on top of the simple one?

  // declare events (NOTE: consider which fields should be indexed)
  event AttributeTypeAdded(uint256 indexed attribute, string description);
  event AttributeTypeRemoved(uint256 indexed attribute);
  event ValidatorAdded(address indexed validator, string description);
  event ValidatorRemoved(address indexed validator);
  event ValidatorApprovalAdded(address validator, uint256 indexed attribute);
  event ValidatorApprovalRemoved(address validator, uint256 indexed attribute);
  event AttributeAdded(
    address validator,
    address indexed attributee,
    uint256 attribute
  );
  event AttributeRemoved(
    address validator,
    address indexed attributee,
    uint256 attribute
  );
  // ZEPPELIN-AUDIT: I think validator and attribute should always be indexed.

  // the contract owner may declare attributes recognized by the jurisdiction
  function addAttributeType(
    uint256 _id,
    bool _restrictedAccess,
    bool _onlyPersonal,
    address _secondarySource,
    uint256 _secondaryId,
    uint256 _minimumStake,
    uint256 _jurisdictionFee,
    string _description
  ) external;

  // the owner may also remove attributes - necessary first step before updating
  // ZEPPELIN-AUDIT:
  // Updating what?
  // Explain if attribute type ids can be reused or not.
  function removeAttributeType(uint256 _id) external;

  // the jurisdiction can add new validators who can verify and sign attributes
  function addValidator(address _validator, string _description) external;

  // the jurisdiction can remove validators, invalidating submitted attributes
  // ZEPPELIN-AUDIT: explain what happens to future validations from this validator.
  function removeValidator(address _validator) external;

  // the jurisdiction approves validators to assign predefined attributes
  function addValidatorApproval(
    address _validator,
    uint256 _attribute
    // ZEPPELIN-AUDIT: is this attributeTypeId?
  ) external;

  // the jurisdiction may remove a validator's ability to approve an attribute
  // ZEPPELIN-AUDIT: explain what happens to past and future validations from the
  // removed validator.
  function removeValidatorApproval(
    address _validator,
    uint256 _attribute
    // ZEPPELIN-AUDIT: is this attributeTypeId?
  ) external;

  // approved validators may add attributes directly to a specified address
  function addAttributeTo(
    // ZEPPELIN-AUDIT: why not just addAttribute?
    address _who,
    uint256 _attribute,
    // ZEPPELIN-AUDIT: is this attributeTypeId?
    uint256 _value
  ) external payable;

  // the jurisdiction owner and issuing validators may remove attributes
  // ZEPPELIN-AUDIT: is the removal permanent?
  // Can the attribute be added again? Or is this an implementation detail that should
  // be explained only on the implementation contract?
  function removeAttributeFrom(address _who, uint256 _attribute) external;
  // ZEPPELIN-AUDIT: why not just removeAttribute?
  // ZEPPELIN-AUDIT: is this attributeTypeId?

  // external interface for getting the number of designated validators
  function countAvailableValidators() external view returns (uint256);
  // ZEPPELIN-AUDIT: why available? Are there unavailable validators?

  // external interface for getting a validator's address by index
  function getAvailableValidator(uint256 _index) external view returns (address);
  // ZEPPELIN-AUDIT: why available? Are there unavailable validators?

  // external interface to check if validator is approved to issue an attribute
  function isApproved(
    address _validator,
    uint256 _attribute
    // ZEPPELIN-AUDIT: is this attributeTypeId?
  ) external view returns (bool);
  // ZEPPELIN-AUDIT: this function definition might be confusing. Does it mean that
  // the validator has that attribute, or that the validator can validate that
  // attribute? You need to read the docs to understand, which probably means that
  // the name should be improved. canValidate?

  // external interface for getting the description of an attribute by ID
  function getAttributeInformation(
    // ZEPPELIN-AUDIT: getAttributeTypeInformation?
    uint256 _attribute
    // ZEPPELIN-AUDIT: is this attributeTypeId?
  ) external view returns (
    string description,
    bool isRestricted,
    bool isOnlyPersonal,
    address secondarySource,
    uint256 secondaryId,
    // ZEPPELIN-AUDIT: secondaryAttributeTypeId/attributeTypeIdOnSecondarySource
    uint256 minimumRequiredStake,
    uint256 jurisdictionFee
  );

  // external interface for getting the description of a validator by ID
  function getValidatorInformation(
    address _validator
  ) external view returns (
    address signingKey,
    // ZEPPELIN-AUDIT: instead of signingKey, isn't this just the account address?
    string description
  );

  // external interface for determining the validator of an issued attribute
  function getAttributeValidator(
    address _who,
    uint256 _attribute
  ) external view returns (address validator, bool isStillValid);
  // ZEPPELIN-AUDIT: what is isStillValid?
}
