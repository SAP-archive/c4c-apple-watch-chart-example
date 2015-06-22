//
//  SalesInterfaceController.m
//  ODataExample
/*
Copyright 2015 SAP America Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

#import "SalesInterfaceController.h"
#import "OpportunitiesRowController.h"
#import "ReloadDataRowController.h"
#import "Constants.h"

#define ANIMATION_DURATION 1.0
#define MAX_NUM_BARS 10
#define NUM_IMAGES 100

@interface SalesInterfaceController()
{
    NSString * accountID;
    int barIndex;
    float max;
    int inc;
    int multiplier;
    NSString * unit;
    NSArray *bars;
    NSArray *axisLabels;
    NSArray *color_bars;
    NSArray *colors;
    NSArray * opportunities;
}

@property (nonatomic, weak) IBOutlet WKInterfaceTable * tblOpportunities;
@property (nonatomic, weak) IBOutlet WKInterfaceGroup * grpChart;

//Axis Labels
@property (nonatomic, weak) IBOutlet WKInterfaceLabel * lbl1;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel * lbl2;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel * lbl3;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel * lbl4;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel * lbl5;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel * lbl6;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel * lbl7;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel * lbl8;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel * lbl9;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel * lbl10;

//These are our black masks
@property (nonatomic, weak) IBOutlet WKInterfaceGroup * bar1;
@property (nonatomic, weak) IBOutlet WKInterfaceGroup * bar2;
@property (nonatomic, weak) IBOutlet WKInterfaceGroup * bar3;
@property (nonatomic, weak) IBOutlet WKInterfaceGroup * bar4;
@property (nonatomic, weak) IBOutlet WKInterfaceGroup * bar5;
@property (nonatomic, weak) IBOutlet WKInterfaceGroup * bar6;
@property (nonatomic, weak) IBOutlet WKInterfaceGroup * bar7;
@property (nonatomic, weak) IBOutlet WKInterfaceGroup * bar8;
@property (nonatomic, weak) IBOutlet WKInterfaceGroup * bar9;
@property (nonatomic, weak) IBOutlet WKInterfaceGroup * bar10;

//These are our colored bars
@property (nonatomic, weak) IBOutlet WKInterfaceGroup * color_bar1;
@property (nonatomic, weak) IBOutlet WKInterfaceGroup * color_bar2;
@property (nonatomic, weak) IBOutlet WKInterfaceGroup * color_bar3;
@property (nonatomic, weak) IBOutlet WKInterfaceGroup * color_bar4;
@property (nonatomic, weak) IBOutlet WKInterfaceGroup * color_bar5;
@property (nonatomic, weak) IBOutlet WKInterfaceGroup * color_bar6;
@property (nonatomic, weak) IBOutlet WKInterfaceGroup * color_bar7;
@property (nonatomic, weak) IBOutlet WKInterfaceGroup * color_bar8;
@property (nonatomic, weak) IBOutlet WKInterfaceGroup * color_bar9;
@property (nonatomic, weak) IBOutlet WKInterfaceGroup * color_bar10;

@end


@implementation SalesInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    //Get the AccountId from the context
    accountID =  [context objectForKey:FILTER_ACCOUNT_ACCOUNTID];
    
    [self setTitle:[context objectForKey:SELECT_ACCOUNT_ACCOUNT_NAME]];
    
    //Create an Array of bars
    axisLabels = @[self.lbl1, self.lbl2,self.lbl3,self.lbl4,self.lbl5,self.lbl6,self.lbl7,self.lbl8,self.lbl9,self.lbl10];
    
    //Create an Array of bars
    bars = @[self.bar1, self.bar2,self.bar3,self.bar4,self.bar5,self.bar6,self.bar7,self.bar8,self.bar9,self.bar10];
    
    //Create an Array of color_bars
    color_bars = @[self.color_bar1, self.color_bar2,self.color_bar3,self.color_bar4,self.color_bar5,self.color_bar6,self.color_bar7,self.color_bar8,self.color_bar9,self.color_bar10];
    
    //Generate some colors to make the bars
    colors = [self createBarColors:MAX_NUM_BARS];
}

- (void)willActivate {
    [super willActivate];
    
    //Get the Opportunities
    [self refreshData];
}

#pragma mark - Data Loading

-(void)refreshData
{
    barIndex = 0;
    for(int i=0; i < bars.count; i++){
        [bars[i] setBackgroundImageNamed:@"black_bar_0"];
    }
    [WKInterfaceController openParentApplication:@{ACTION:COLLECTIION_OPPORTUNITY,FILTER_ACCOUNT_ACCOUNTID: accountID}
                        reply:^(NSDictionary *replyInfo, NSError *error) {
        
        opportunities = [replyInfo objectForKey:COLLECTIION_OPPORTUNITY];
        
        if(opportunities.count > 0){
            [self.grpChart setHidden:NO];
            max = [self findMax:opportunities];

            [self updateAxisLabels];
            
            
            if(opportunities&&[opportunities count]>0){
                //Animate the bars when the page is displayed
                [self animateNextBar];
                
                [self loadOpportunities:opportunities];
            }
        }else{
            [self.grpChart setHidden:YES];
            [self loadOpportunities:opportunities];
        }
    }];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}


#pragma mark - Chart

-(void)animateNextBar
{
    //Set the background image for animating
    [bars[barIndex] setBackgroundImageNamed:@"black_bar_"];
    
    //get a random number to set the bar to between 0 & NUM_IMAGES
    
    NSDictionary * opportunity = opportunities[barIndex];
    float value = [[opportunity objectForKey:OPPORTUNITY_EXPECTED_VALUE] floatValue];
    
    int scaledValue = round(value/(inc*multiplier/10));
    
    //We want to animate at the same acceleration so change duration based on bar position
    float duration = 1.0;
    
    //Lets adjust the animation speed based on how many images we need to animate
    if(scaledValue > 0)
    {
        duration = ANIMATION_DURATION/(NUM_IMAGES/(float)scaledValue);
        
        //Adjust the bars to center of the axis labels
        if(scaledValue > 20){
            scaledValue = scaledValue-5;
        }else if(scaledValue > 10){
            scaledValue = scaledValue-2;
        }else if(scaledValue > 5){
            scaledValue = scaledValue-1;
        }
    }else{
        //Need to show a tiny bar when value is too small to be rendered
        scaledValue = 2;
        duration = 0.1;
    }
    
    
    //Animate the bar to a random position from 0-99
    [bars[barIndex] startAnimatingWithImagesInRange:NSMakeRange(0, scaledValue)
                                           duration: duration
                                        repeatCount: 1];
    
    //Set the color of the bar
    [color_bars[barIndex] setBackgroundColor:colors[barIndex]];
    
    //Goto the next bar
    barIndex++;
    
    //Only show up to max 10 results
    int numBars = (opportunities.count > MAX_NUM_BARS ? MAX_NUM_BARS : (int)opportunities.count);
    
    //If we are not at the last bar animate the next bar
    if(barIndex < numBars){
        [self performSelector:@selector(animateNextBar) withObject:nil afterDelay:0.01];
    }
}

-(float)findMax:(NSArray *)values
{
    float maxVal = 0;
    for(NSDictionary * dict in values){
        NSString * value = [dict objectForKey:OPPORTUNITY_EXPECTED_VALUE];
        if([value floatValue] > maxVal){
            maxVal = [value floatValue];
        }
    }
    return maxVal;
}

//Generate the correct Axis labels based on the range of values
-(void)updateAxisLabels
{
    unit = @"m";
    float increment = max/10.0;
    float mil = 1000000.0;
    float tho = 1000.0;
    if(increment > 100.0*mil){
        multiplier = mil;
        increment = increment/mil;
        inc = round(increment/100.0)*100;
        unit = @"m";
    }else if(increment > 10.0*mil){
        multiplier = mil;
        increment = increment/mil;
        inc = round(increment/10.0)*10;
        unit = @"m";
    }else if(increment > mil){
        multiplier = mil;
        increment = increment/mil;
        inc = round(increment);
        unit = @"m";
    }else if(increment > 100.0*tho){
        multiplier = tho;
        increment = increment/tho;
        inc = round(increment/100.0)*100;
        unit = @"k";
    }else if(increment > 10.0*tho){
        multiplier = tho;
        increment = increment/tho;
        inc = round(increment/10.0)*10;
        unit = @"k";
    }else if(increment > tho){
        multiplier = tho;
        increment = increment/tho;
        inc = round(increment);
        unit = @"k";
    }else{
        multiplier = 1;
        inc = round(increment);
        unit = @"";
    }
    int count = 1;
    for(WKInterfaceLabel* lbl in axisLabels){
        BOOL useDecimal = NO;
        float val = (inc*count++);
        if(multiplier == mil){
            if(val >= 1000){
                useDecimal = YES;
                val = val/1000.0;
                unit = @"bn";
            }
        }else if(multiplier == tho){
            if(val >= 1000){
                useDecimal = YES;
                val = val/1000.0;
                unit = @"m";
            }
        }else{
            if(val >= 1000){
                useDecimal = YES;
                val = val/1000.0;
                unit = @"k";
            }
        }
        if(useDecimal){
            lbl.text = [NSString stringWithFormat:@"%.1f%@", val, unit];
        }else{
            lbl.text = [NSString stringWithFormat:@"%.0f%@", val, unit];
        }
    }
}

//Handy color generator
-(NSMutableArray*)createBarColors:(int)numColors
{
    NSMutableArray *colorsArr = [NSMutableArray array];
    
    float incr = 1.0/numColors;
    for (float hue = 0.0; hue < 1.0; hue += incr) {
        UIColor *color = [UIColor colorWithHue:hue
                                    saturation:1.0
                                    brightness:1.0
                                         alpha:1.0];
        [colorsArr addObject:color];
    }
    return colorsArr;
}

#pragma mark - TableView

- (void)loadOpportunities:(NSArray*)items {
    NSString * loadingComplete = @"Loading Complete...";
    if(items.count == 0){
        items = @[@{OPPORTUNITY_NAME:loadingComplete,OPPORTUNITY_EXPECTED_VALUE:@""}];
    }
    
    int count = (int)items.count;
    
    if(count > MAX_NUM_BARS){
        count = MAX_NUM_BARS;
    }
    
    NSMutableArray * rowTypes = [[NSMutableArray alloc] init];
    for(int i=0; i< count; i++){
        [rowTypes addObject:@"OpportunitiesRowController"];
    }
    
    //Add the reload data row
    [rowTypes addObject:@"ReloadDataRowController"];
    
    [self.tblOpportunities setRowTypes:rowTypes];
    
    // Iterate over the rows and set the label for each one.
    for (int i = 0; i < count; i++) {
        // Get the to-do item data.
        NSDictionary* item = items[i];
        
        NSString* name = [item objectForKey:OPPORTUNITY_NAME];
        NSString* value = [item objectForKey:OPPORTUNITY_EXPECTED_VALUE];
        
        // Assign the text to the row's label.
        OpportunitiesRowController* row = [self.tblOpportunities rowControllerAtIndex:i];
        
        row.lblName.text = name;
        
        if(![name isEqualToString:loadingComplete]){
            if(multiplier > 1){
                if([value floatValue] >= 1000000.0){
                    row.lblValue.text = [NSString stringWithFormat:@"$%.1f%@", [value floatValue]/multiplier, @"m" ];
                }else if([value floatValue] >= 1000.0){
                    row.lblValue.text = [NSString stringWithFormat:@"$%.1f%@", [value floatValue]/multiplier, @"k" ];
                }else{
                    row.lblValue.text = [NSString stringWithFormat:@"$%.1f%@", [value floatValue], @"" ];
                }
                
            }else{
                row.lblValue.text = [NSString stringWithFormat:@"$%.0f%@", [value floatValue]/multiplier, unit ];
            }
        }else{
            row.lblValue.text = @"No Opportunities Found";
        }
        [row.grpIcon setBackgroundColor:colors[i]];

    }
}

-(void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex
{
    //if the last row was selected
    if(rowIndex == table.numberOfRows-1){
        ReloadDataRowController * row = [table rowControllerAtIndex:rowIndex];
        
        row.lblReloadData.text = @"Loading...";
        
        [self refreshData];
        
        [table scrollToRowAtIndex:0];
    }
}
@end




