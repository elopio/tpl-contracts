const { assertRevert } = require('./helpers/assertRevert');
const BasicJurisdiction = artifacts.require('BasicJurisdiction');
const BigNumber = web3.BigNumber;

const should = require('chai')
  .use(require('chai-bignumber')(BigNumber))
  .should();

contract('BasicJurisdiction', function ([owner, owner2, validator, attributee, attributee2, anybody, nobody]) {
  beforeEach(async function () {
    this.jurisdiction = await BasicJurisdiction.new(
      {from: owner}
    );
    await this.jurisdiction.initialize();
    this.attributeTypeId = 1;
    await this.jurisdiction.addAttributeType(
        this.attributeTypeId, false, false, 0, 0, 0, 0, "test attribute");
  });

  context('when a validator is added', function () {
    beforeEach(async function () {
      await this.jurisdiction.addValidator(
        validator, "test validator",
        {from: owner}
      );
      await this.jurisdiction.addValidatorApproval(
        validator, this.attributeTypeId,
        {from: owner}
      );
    });

    context('when an attribute is added', function () {
      beforeEach(async function () {
        dummyAttributeValue = 10;
        await this.jurisdiction.addAttributeTo(
          attributee, this.attributeTypeId, dummyAttributeValue,
          {from: validator}
        );
      });

      context('when a validator is removed', function () {
        beforeEach(async function () {
          await this.jurisdiction.removeValidator(validator, {from: owner});
        });

        it('cannot remove attributes', async function () {
          // ZEPPELIN-AUDIT: Issue
          // HIGH: Removed validators preserve their issuing permissions
          // Part 1.
          await assertRevert(
            this.jurisdiction.removeAttributeFrom(
              attributee, this.attributeTypeId,
              {from: validator}
            )
          );
        });
      }); // when a validator is removed
    }); // when an attribute is added

    context('when a validator is removed', function () {
      beforeEach(async function () {
        await this.jurisdiction.removeValidator(validator, {from: owner});
      });

      context('when jurisdiction is transfered to new owner', function () {
        beforeEach(async function () {
          await this.jurisdiction.transferOwnership(
            owner2,
            {from: owner}
          );
        });

        context('when validator is readded', function () {
          beforeEach(async function () {
            await this.jurisdiction.addValidator(
              validator, "test validator",
              {from: owner2}
            );
          });

          it('cannot approve attributes', async function() {
            // ZEPPELIN-AUDIT: Issue
            // HIGH: Removed validators preserve their issuing permissions
            // Part 2.
            await assertRevert(
              this.jurisdiction.addAttributeTo(
                attributee2, this.attributeTypeId, 0,
                {from: validator}
              )
            );
          });

        }); // when validator is readded
      }); // when jurisdiction is transfered to new owner
    }); // when a validator is removed

    it('can get attribute with 0 value', async function() {
      // ZEPPELIN-AUDIT: Issue
      // HIGH: Ambiguous return value for the getAttribute function
      // Part 1
      expectedAttributeValue = 0;
      await this.jurisdiction.addAttributeTo(
        attributee, this.attributeTypeId, expectedAttributeValue,
        {from: validator}
      );
      const attributeValue = await this.jurisdiction.getAttribute(attributee, this.attributeTypeId);
      attributeValue.should.be.bignumber.equal(expectedAttributeValue);
    });

  }); // when a validator is added

  it('cannot get nonexistent attributes', async function () {
    // ZEPPELIN-AUDIT: Issue
    // HIGH: Ambiguous return value for the getAttribute function
    // Part 2
    const nonexistentAttributeId = 100;
    await assertRevert(
      this.jurisdiction.getAttribute(nobody, nonexistentAttributeId)
    );
  });

}); // BasicJurisdiction
