import {
    Model,
    DataTypes,
    InferAttributes,
    InferCreationAttributes,
    CreationOptional,
    NonAttribute,
    HasOneGetAssociationMixin,
    HasOneCreateAssociationMixin,
} from '@sequelize/core';
import {
    PrimaryKey,
    Attribute,
    AutoIncrement,
    NotNull,
    HasOne,
    BelongsTo,
} from '@sequelize/core/decorators-legacy';

class Person extends Model<InferAttributes<Person>, InferCreationAttributes<Person>> {
    @Attribute(DataTypes.INTEGER)
    @AutoIncrement
    @PrimaryKey
    declare id: CreationOptional<number>;

    @HasOne(() => DrivingLicense, {
        inverse: {
            as: "owner",
            scope: {
                ownerId: 1
            }
        }
    })
    declare drivingLicense?: NonAttribute<DrivingLicense>;

    declare getDrivingLicense: HasOneGetAssociationMixin<DrivingLicense>;
    declare craeteDrivingLicense: HasOneCreateAssociationMixin<DrivingLicense>;
}

class DrivingLicense extends Model<
    InferAttributes<DrivingLicense>,
    InferCreationAttributes<DrivingLicense>
> {
    @Attribute(DataTypes.INTEGER)
    @AutoIncrement
    @PrimaryKey
    declare id: CreationOptional<number>;

    // This is the foreign key
    @Attribute(DataTypes.INTEGER)
    @NotNull
    declare ownerId: number;
}

async function query() {
    var person = await Person.findOne();

    var driverL = await person?.getDrivingLicense({
        where: {

        }
    })

}