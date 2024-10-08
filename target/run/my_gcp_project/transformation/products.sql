
  
    USE [APIData];
    USE [APIData];
    
    

    

    
    USE [APIData];
    EXEC('
        create view "Landing"."Products__dbt_tmp__dbt_tmp_vw" as -- transformation/products.sql




with raw_data as (
    select
        -- Extract the main fields from the JSON in _airbyte_data
        JSON_VALUE(_airbyte_data, ''$.id'') as product_id,
        JSON_VALUE(_airbyte_data, ''$.title'') as product_title,
        JSON_VALUE(_airbyte_data, ''$.description'') as product_description,
        JSON_VALUE(_airbyte_data, ''$.category'') as product_category,
        JSON_VALUE(_airbyte_data, ''$.price'') as product_price,
        JSON_VALUE(_airbyte_data, ''$.discountPercentage'') as discount_percentage,
        JSON_VALUE(_airbyte_data, ''$.rating'') as product_rating,
        JSON_VALUE(_airbyte_data, ''$.stock'') as stock_quantity,
        JSON_VALUE(_airbyte_data, ''$.sku'') as sku,
        JSON_VALUE(_airbyte_data, ''$.weight'') as product_weight,
        JSON_VALUE(_airbyte_data, ''$.dimensions.width'') as product_width,
        JSON_VALUE(_airbyte_data, ''$.dimensions.height'') as product_height,
        JSON_VALUE(_airbyte_data, ''$.dimensions.depth'') as product_depth,
        JSON_VALUE(_airbyte_data, ''$.warrantyInformation'') as warranty_info,
        JSON_VALUE(_airbyte_data, ''$.shippingInformation'') as shipping_info,
        JSON_VALUE(_airbyte_data, ''$.availabilityStatus'') as availability_status,
        JSON_VALUE(_airbyte_data, ''$.meta.createdAt'') as created_at,
        JSON_VALUE(_airbyte_data, ''$.meta.updatedAt'') as updated_at
    from Landing.Landing_raw__stream_API_Source_Connector
)

select * from raw_data;;
    ')

EXEC('
            SELECT * INTO "APIData"."Landing"."Products__dbt_tmp" FROM "APIData"."Landing"."Products__dbt_tmp__dbt_tmp_vw" 
    OPTION (LABEL = ''dbt-sqlserver'');

        ')

    
    EXEC('DROP VIEW IF EXISTS Landing.Products__dbt_tmp__dbt_tmp_vw')



    
    use [APIData];
    if EXISTS (
        SELECT *
        FROM sys.indexes with (nolock)
        WHERE name = 'Landing_Products__dbt_tmp_cci'
        AND object_id=object_id('Landing_Products__dbt_tmp')
    )
    DROP index "Landing"."Products__dbt_tmp".Landing_Products__dbt_tmp_cci
    CREATE CLUSTERED COLUMNSTORE INDEX Landing_Products__dbt_tmp_cci
    ON "Landing"."Products__dbt_tmp"

   


  