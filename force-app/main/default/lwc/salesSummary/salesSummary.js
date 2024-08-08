import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import USER_ID from "@salesforce/user/Id";
import getSalesUsers from '@salesforce/apex/SalesmanController.getSalesUsers';
import getMonthlySalesData from '@salesforce/apex/SalesmanController.getMonthlySalesData';

export default class SalesmanSalesSummary extends LightningElement {
    @track salesmen = [];
    @track salesData;
    @track error;
    @track selectedSalesmanId = USER_ID;

    @track columns = [
        {
            label: 'Month',
            fieldName: 'month',
            type: 'text',
        },
        {
            label: 'Total Sales',
            fieldName: 'totalSales',
            type: 'currency',
            cellAttributes: {
                class: { fieldName: 'cssClass' }
            }
        }
    ];

    @wire(getSalesUsers)
    wiredSalesUsers({ error, data }) {
        if (data) {
            this.salesmen = data.map(user => ({
                label: user.Name,
                value: user.Id
            }));
            this.error = undefined;
            // Set the default salesman ID to the current user's ID
            this.setDefaultSalesman();
        } else if (error) {
            this.error = error;
            this.salesmen = [];
        }
    }

    setDefaultSalesman() {
        if (this.salesmen.length > 0) {
            // Ensure the current user is salesman
            const defaultSalesman = this.salesmen.find(user => user.value === this.selectedSalesmanId);
            if (defaultSalesman) {
                this.selectedSalesmanId = defaultSalesman.value;
            }
        }
    }

    handleSalesmanChange(event) {
        this.selectedSalesmanId = event.detail.value;
        this.fetchMonthlySalesData(this.selectedSalesmanId);
    }

    fetchMonthlySalesData(userId) {
        getMonthlySalesData({ userId })
            .then(result => {
                if (result.length === 0) {
                    this.showToast('No Sales Data', 'This salesman has no sales details in the last 12 months.', 'warning');
                } else {
                    const currentDate = new Date();
                    let filledSalesData = [];

                    // Create a Set of all available months from the result
                    const salesMap = new Map(result.map(record => [record.month, record.totalSales]));
                    // Loop through the last 12 months
                    for (let i = 0; i < 12; i++) {
                        let date = new Date(currentDate.getFullYear(), currentDate.getMonth() - i, 1);
                        let monthYearKey = date.getFullYear() + '-' + String(date.getMonth() + 1).padStart(2, '0');
                        let totalSales = salesMap.get(date.getMonth() + 1);
                        // Add the month with totalSales or 0 if not present
                        filledSalesData.unshift({
                            month: monthYearKey,
                            totalSales: totalSales || 0,
                            cssClass: totalSales ? '' : 'slds-text-color_error'
                        });
                    }

                    this.salesData = filledSalesData;
                    this.error = undefined;
                }
            })
            .catch(error => {
                this.error = error;
                this.salesData = [];
            });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }

}


